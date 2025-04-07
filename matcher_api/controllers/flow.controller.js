// ===== IMPORTS =====
const db = require("../models");
const User = db.users;
const Flow = db.flow;
const Op = db.Sequelize.Op;
const { determineScore, distanceBtw2Coord, getAgeFromDate } = require("../functions/flow.functions");
const { requestStackPerFlow, profileConsultedDelay } = require("../config/flow.config");
const { getUserFromID } = require("../functions/users.function");
// ==========



exports.getFlow = async (req, res) => {
    // If there is no uid provided (really strange :/)
    if (req.uid==null){
        return res.status(400).send({ message: "Invalid user" });
    }

    try {
        // Get User Request datas
        const user = await User.findOne({ where: { uid: req.uid } });
        if (user==null){
            return res.status(400).send({ message: "Invalid user" });
        } else if (user.isVerif==false){
            return res.status(401).send({ message: "Please verify your email first" });
        }

        // Get user flow datas
        const userFlow = await Flow.findOne({ where: { uid: req.uid } });

        if(userFlow!=null){

            if(req.query.current!=null && (userFlow.recommendation.length>0 || userFlow.futureRecommendation.length>0)){
                let recommendationArray = (userFlow.recommendation || []).slice(userFlow.index);
                let futureRecommendationArray = (userFlow.futureRecommendation || []);
                return res.status(200).send([
                ...recommendationArray,
                ...futureRecommendationArray
                ]);
            } 

            let toUpdate = {}

            console.log("SUPER TEST : ", userFlow.index);

            const recommendationLength = userFlow.recommendation.length;
            const swipedProfile = userFlow.recommendation[userFlow.index];
            if(swipedProfile){
                userFlow.consultedProfiles.push({
                    "uid": swipedProfile["uid"],
                    "delay": Math.floor(new Date().getTime() / 1000)
                })
                toUpdate["consultedProfiles"] = userFlow.consultedProfiles;

                userFlow.index+=1;
                toUpdate["index"] = userFlow.index;

                const userSwiped = await User.findOne({ where: { uid: swipedProfile["uid"] } });
                if (user!=null){
                    userSwiped.statistics.view++;
                    if(userFlow.consultedProfiles.length>2){
                        const currentSwiped = userFlow.consultedProfiles[userFlow.consultedProfiles.length-1];
                        const beforeCurrentSwiped = userFlow.consultedProfiles[userFlow.consultedProfiles.length-2];
                        userSwiped.statistics.time+=Math.min(10, currentSwiped["delay"]-beforeCurrentSwiped["delay"]);
                    }
                    await userSwiped.update({ 
                        statistics: userSwiped.statistics,
                    });
                }
            }

            if (userFlow.index >= recommendationLength && userFlow.futureRecommendation!=[]){
                userFlow.index=0;
                userFlow.recommendation=userFlow.futureRecommendation;
                userFlow.futureRecommendation=[];

                toUpdate["index"]=userFlow.index;
                toUpdate["recommendation"]=userFlow.recommendation;
                toUpdate["futureRecommendation"]=userFlow.futureRecommendation;
            } 
            

            await userFlow.changed("consultedProfiles", true);
            await userFlow.update(toUpdate);
            await userFlow.save();   
        }

        // If user need reset of his flow
        // Or if user flow is not defined
        // Or if user flow index need to get future recommendations
        if (req.query.reset!=null || userFlow==null || (userFlow.index >= userFlow.recommendation.length-2 && userFlow.futureRecommendation.length === 0)){

            let userFlowConsultedProfilesUID = [];
            // List of all consulted profiles uid
            if(userFlow!=null){
                userFlowConsultedProfilesUID = userFlow.consultedProfiles.map(obj => obj.uid);
            }

            let alreadyRecommended = [];
            if (userFlow!= null && userFlow.recommendation) {
                alreadyRecommended = userFlow.recommendation.map(item => item.uid);
            }

            // Get dates for filters
            const currentDate = new Date();

            function createDate(year, month, day, hours, minutes, seconds, milliseconds) {
                const date = new Date(Date.UTC(year, month, day, hours, minutes, seconds, milliseconds));
                return date;
            }
            
            const ageMaxDate = createDate(currentDate.getUTCFullYear() - 1 - user.ageMaxSought, 0, 1, 0, 0, 0, 0);
            const ageMaxDateString = ageMaxDate.toISOString().slice(0, 10);
            
            const ageMinDate = createDate(currentDate.getUTCFullYear() + 1 - user.ageMinSought, 0, 1, 0, 0, 0, 0);
            const ageMinDateString = ageMinDate.toISOString().slice(0, 10);

            const currentUserAge = getAgeFromDate(user.birthday);

            // Search compatible users with filters
            let usersCompatible = await User.findAll({ where: {
                [Op.and]: [
                    { uid: {
                        [Op.and]: [
                            { [Op.not]: user.uid },
                            { [Op.notIn]: userFlowConsultedProfilesUID},
                            { [Op.notIn]: alreadyRecommended},
                            { [Op.notIn]: Object.keys(user.likesGiven)},
                            { [Op.notIn]: Object.keys(user.likesReceived)},
                        ]}
                    },
                    { paused: { [Op.not]: true } },
                    { gender: { [Op.in]: user.attractions }, },
                    { attractions: {[Op.contains]: [user.gender]} },
                    { relationShip: user.relationShip },
                    { birthday: { [Op.between]: [ageMaxDateString, ageMinDateString]} },
                    { ageMinSought: { [Op.lte]: currentUserAge } },
                    { ageMaxSought: { [Op.gte]: currentUserAge } },
                ]
            }});
            

            console.log("barrière 1");
            console.log(usersCompatible);
            // Calculate points for each found users
            const currentUserCoord = user.location.coordinates;

            // Remove all users outside search distance
            usersCompatible = usersCompatible.filter(usr => {
                const userCoord = usr.location.coordinates;
                const distance = distanceBtw2Coord(currentUserCoord[0], currentUserCoord[1], userCoord[0], userCoord[1]);
                return distance <= user.searchDist;
            });

            console.log("barrière 2");
            console.log(usersCompatible);

            let usersCompatibleWithScore = []
            usersCompatible.forEach(userCompatible => {
                try{
                    const userCompatibleCoord = userCompatible.location.coordinates;
                    usersCompatibleWithScore.push({
                        "uid": userCompatible.uid,
                        "score": determineScore(user, userCompatible),
                        "name": userCompatible.name,
                        "hobbies": userCompatible.hobbies,
                        "gender": userCompatible.gender,
                        "bio": userCompatible.bio,
                        "age": getAgeFromDate(userCompatible.birthday),
                        "distance": Math.round(distanceBtw2Coord(currentUserCoord[0], currentUserCoord[1], userCompatibleCoord[0], userCompatibleCoord[1])),
                        "liked": user.likesGiven[userCompatible.uid]!=null,
                    });
                } catch(e){
                    console.log("Error score calculation flow: ",e);
                }
            });


            // Sort found user in DESC from score
            usersCompatibleWithScore.sort((a, b) => b.score - a.score);
            usersCompatibleWithScore=usersCompatibleWithScore.slice(0, requestStackPerFlow);

            console.log("barrière 3");
            console.log(usersCompatibleWithScore);

            // If user's flow doesn't exist create it (flow index set at 0 by default)
            if (userFlow==null){
                console.log("test 20")
                const future_flow={
                    "uid": req.uid,
                    "recommendation": usersCompatibleWithScore,
                }

                await Flow.create(future_flow);
                console.log(usersCompatibleWithScore);
                return res.status(200).send(usersCompatibleWithScore);
            } 
            // If user's flow need update
            else {
                await userFlow.update({
                    "futureRecommendation": usersCompatibleWithScore, 
                })
                await userFlow.save();
                return res.status(200).send(usersCompatibleWithScore);
            }
        } else {
            return res.status(200).send();
        }
    } catch (err) {
        console.error("Error in flow: ", err);
        return res.status(500).send({ message: "Internal server error" });
    }
};



