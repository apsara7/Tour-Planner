import CryptoJS from "crypto-js";

const secretKey = process.env.REACT_APP_TOKEN_SECRET;

// Encrypt JSON object
export const encryptData = (data) => {
  try {
    return CryptoJS.AES.encrypt(JSON.stringify(data), secretKey).toString();
  } catch (err) {
    console.error("Error encrypting:", err);
    throw err;
  }
};

// Decrypt JSON object
export const decryptData = (cipherText) => {
  try {
    const bytes = CryptoJS.AES.decrypt(cipherText, secretKey);
    return JSON.parse(bytes.toString(CryptoJS.enc.Utf8));
  } catch (err) {
    console.error("Error decrypting:", err);
    return null;
  }
};
