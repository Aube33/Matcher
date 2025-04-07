const express = require('express');
const fs = require('fs');
const path = require('path');
const multer = require('multer');
const sharp = require("sharp");
const zlib = require('zlib');
const util = require('util');
const winston = require('winston');

//===== CONFIG =====
const LOGS_FOLDER="logs";
const ERROR_LOG_FILE="errors.log";
const LOG_FILE="logs.log";

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  defaultMeta: { service: 'user-service' },
  transports: [
    new winston.transports.File({ filename: `${LOGS_FOLDER}/${ERROR_LOG_FILE}`, level: "error"}),
    new winston.transports.File({ filename: `${LOGS_FOLDER}/${LOG_FILE}`, level: "info"}),
  ],
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple(),
  }));
}

const app = express();
const port = 3001;

const uploadDir = path.join(__dirname, 'uploads');
fs.mkdirSync(uploadDir, { recursive: true });

const allowedImagesIndex=["0","1","2"];
const profileImgFilename = "profile.webp";

const storage = multer.memoryStorage();
const uploadImageArray = multer({ storage: storage }).array('images', 3);
const uploadImageProfile = multer({ storage: storage }).array('image', 1);


const readFile = util.promisify(fs.readFile);
//==================



//===== FUNCTIONS =====
async function isImage(filePath) {
  try {
      await sharp(filePath).metadata();
      return true;
  } catch (error) {
      return false;
  }
}

function compressImage(filepath) {
  return sharp(filepath)
    .toBuffer()
    .then(buffer => {
      const compressedBuffer = zlib.gzipSync(buffer);
      return { filename: path.basename(filepath), data: compressedBuffer };
    });
}

function logUpload(userId, filename, fileSize) {
  logger.info(`User [${userId}] uploaded file ${filename} : ${fileSize}`);
}

function logRequest(userId, filename) {
  logger.info(`User [${userId}] get file ${filename}`);

}
//=====================



//===== ENDPOINTS =====
//Endpoint pour l'upload de l'image de profil
app.post('/upload/profile/:uid', function(req, res, next) {
  uploadImageProfile(req, res, async function (err) {
    if (err) {
      return res.status(403).send("No images or too much images");
    }

    const userId = req.params.uid;
    if (!userId){
        return res.status(403).send('Unauthorized');
    }

    if (req.files.length > 1) {
      return res.status(403).send('Maximum images is 1');
    }

    if (req.files.length>0) {
      const file = req.files[0];
      if (!await isImage(file.buffer)) {
        return res.status(403).send(`File ${file.originalname} is not an image`);
      }
    }

    //Creation of folder with user's id
    const userUploadDir = path.join(uploadDir, userId);
    fs.mkdirSync(userUploadDir, { recursive: true });
  
    if (req.files.length>0) {
      const file = req.files[0];
      
      try {
        await sharp(file.buffer)
        .resize(256, 256)
        .webp({ lossless: false, quality: 60, alphaQuality: 80, force: false })
        .toFile(`${userUploadDir}/${profileImgFilename}`)
        .then(() => {
          console.log(`Compressed ${file.originalname} successfully`);
        });

        logUpload(userId, profileImgFilename, file.size);
      } catch (e){
        return res.status(403).send("Compression error")
      }
    } else if (req.files.length==0){
      fs.unlink(`${userUploadDir}/${profileImgFilename}`, (err) => {
        if (err) {
          if (err.code === 'ENOENT') {
            console.error('File does not exist.');
          } else {
            throw err;
          }
        } else {
          console.log('File deleted!');
        }
      });
    }
    
    return res.status(200).send(`Upload successful`);
  })
});

//Endpoint pour l'upload d'images
app.post('/upload/:uid', function(req, res, next) {
  uploadImageArray(req, res, async function (err) {
    if (err) {
      return res.status(403).send("No images or too much images");
    }

    const userId = req.params.uid;
    if (!userId){
        return res.status(403).send('Unauthorized');
    }

    if ((req.body.imagesIndex.length>0) && (req.files && req.files.length>0) && req.files.length!=req.body.imagesIndex.length){
      return res.status(403).send('Bad input');
    } else if (req.files.length > 3) {
      return res.status(403).send('Maximum images is 3');
    }

    if (req.body.imagesIndex.length>0){
      for (let i = 0; i<req.body.imagesIndex.length; i++){
        if (!allowedImagesIndex.includes(req.body.imagesIndex[i])){
          return res.status(403).send('Bad input indexs'); 
        }
      }
    }

    for (let i = 0; i < req.files.length; i++) {
      const file = req.files[i];
      if (!await isImage(file.buffer)) {
        return res.status(403).send(`File ${file.originalname} is not an image`);
      }
    }

    //Creation of folder with user's id
    const userUploadDir = path.join(uploadDir, userId);
    fs.mkdirSync(userUploadDir, { recursive: true });
  
    if (req.files.length>0) {
      for (let i = 0; i < req.files.length; i++) {
        let filename = i.toString();
        if (req.body.imagesIndex!=null && req.body.imagesIndex.length>0){
          filename = req.body.imagesIndex[i];
        }
    
        const file = req.files[i];
        try {
          await sharp(file.buffer)
          .webp({ lossless: false, quality: 60, alphaQuality: 80, force: false })
          .toFile(`${userUploadDir}/${filename}.webp`)
          .then(() => {
            console.log(`Compressed ${file.originalname} successfully`);
          });
  
          logUpload(userId, filename, file.size);
        } catch (e){
          return res.status(403).send("Compression error")
        }
      }
    } else if (req.files.length==0 && req.body.imagesIndex && req.body.imagesIndex.length==1){
      fs.unlink(`${userUploadDir}/${req.body.imagesIndex[0]}.webp`, (err) => {
        if (err) {
          if (err.code === 'ENOENT') {
            console.error('File does not exist.');
          } else {
            throw err;
          }
        } else {
          console.log('File deleted!');
        }
      });
    }
    
    return res.status(200).send(`Upload successful`);
  })
});


// Endpoint récupérer une image
// ?pp = profile avatar image
// ?img = profile images
app.get('/images/:uid', (req, res) => {
  
  const userId = req.params.uid;

  if (!userId){
    return res.status(403).send('Invalid user');
  }

  const userDir = path.join(uploadDir, userId);
  if (!fs.existsSync(userDir)) {
    return res.status(403).send('Unknow user');
  }

  let fileNames = [];
  fileNames = fs.readdirSync(userDir, ['**.webp']);
  const filesPromises = fileNames.map(function (filename) {
    if(!req.query.pp && filename == profileImgFilename) return;
    if(!req.query.img && filename != profileImgFilename) return;

    logRequest(userId, filename)
    const filepath = `${userDir}/${filename}`;
    return readFile(filepath).then(file => ({ [filename.split(".")[0]]: file }));
  });

  Promise.all(filesPromises).then(files => {
    res.status(200).json(Object.assign({},...files));
  }).catch(error => {
    res.status(500).send("Internal server error");
  });
});
//=====================



//===== SERVER =====
app.listen(port, () => {
  console.log(`Serveur démarré sur le port ${port}`);
});
//==================