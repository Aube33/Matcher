// ===== IMPORTS =====
require('dotenv').config();
const fs = require('fs/promises');
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);
const { emailFrom } = require("../config/email.config");
// ==========

const resetPasswordURL = "https://matcher-app.fr/validation?resetpassword=true&token=";
const verificationEmailURL = `http://matcher-api-docker:${process.env.API_PORT}/api/tokens/validate/`;
const changeEmailURL = `http://matcher-api-docker:${process.env.API_PORT}/api/users/change-email/`;

let account_confirmation_htmlTemplate;
let account_deletion_htmlTemplate;
let email_change_htmlTemplate;
let password_change_htmlTemplate;

(async () => {
  try {
    account_confirmation_htmlTemplate = await fs.readFile('email/templates/account_confirmation.html', 'utf8');
    account_deletion_htmlTemplate = await fs.readFile('email/templates/account_deletion.html', 'utf8');
    email_change_htmlTemplate = await fs.readFile('email/templates/email_change.html', 'utf8');
    password_change_htmlTemplate = await fs.readFile('email/templates/password_change.html', 'utf8');
  } catch (error) {
    console.error(`Erreur lors du chargement des templates HTML: ${error.message}`);
    process.exit(1);
  }
})();

exports.sendVerifEmail = async (emailTarget, token) => {
  const urlToken = verificationEmailURL + token;
  try {
    const msg = {
      to: emailTarget,
      from: emailFrom,
      subject: 'Confirmation de votre adresse mail',
      html: account_confirmation_htmlTemplate.replace('{{urlToken}}', urlToken),
    };
    return await sgMail.send(msg);
  } catch (error) {
    console.error(`Erreur lors de l'envoi de l'e-mail de confirmation: ${error.message}`);
    throw error;
  }
};

exports.sendResetPasswordEmail = async (emailTarget, token) => {
  try {
    const urlToken = resetPasswordURL + token;
    const msg = {
      to: emailTarget,
      from: emailFrom,
      subject: 'Réinitialisation du mot de passe',
      html: password_change_htmlTemplate.replace('{{urlToken}}', urlToken),
    };
    console.log("test bizarre ok")
    return await sgMail.send(msg);
  } catch (error) {
    console.error(`Erreur lors de l'envoi de l'e-mail de réinitialisation: ${error.message}`);
    throw error;
  }
};

exports.sendChangeMailEmail = async (emailTarget, token) => {
  const urlToken = changeEmailURL + token;
  try {
    const msg = {
      to: emailTarget,
      from: emailFrom,
      subject: "Changement d'adresse email",
      html: email_change_htmlTemplate.replace('{{urlToken}}', urlToken),
    };
    return await sgMail.send(msg);
  } catch (error) {
    console.error(`Erreur lors de l'envoi de l'e-mail de changement d'adresse: ${error.message}`);
    throw error;
  }
};

exports.sendDeleteAccountEmail = async (emailTarget) => {
  try {
    const msg = {
      to: emailTarget,
      from: emailFrom,
      subject: "Suppression de votre compte Matcher",
      html: account_deletion_htmlTemplate,
    };
    return await sgMail.send(msg);
  } catch (error) {
    console.error(`Erreur lors de l'envoi de l'e-mail de suppression de compte: ${error.message}`);
    throw error;
  }
};
