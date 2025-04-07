const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Flow = sequelize.define('flow', {
    uid: { // User ID who owns the flow
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      allowNull: false,
      unique: true
    },
    index: { // Current recommendation index
      type: DataTypes.SMALLINT,
      defaultValue: 0,
      allowNull: false
    },
    recommendation: { // Pre-recommended profiles in stack
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: []
    },
    futureRecommendation: { // Future stack of recommendation
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: []
    },
    consultedProfiles: { // List of all already consulted profiles
      type: DataTypes.ARRAY(DataTypes.JSONB),
      allowNull: false,
      defaultValue: []
    }
  });

  return Flow;
};
