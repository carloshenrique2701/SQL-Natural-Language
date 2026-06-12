package com.sql_engine.v_1_0.config.security;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.sql_engine.v_1_0.services.exceptions.ai.DatabaseSecurityException;

@Component
public class SecurityDataBaseConfig {

	@Value("${app.crypto.secret}")
	private String secretKeyStr;
	
	public String encrypt (String strToEncrypt) {
		
		try {
			SecretKeySpec secretKey = new SecretKeySpec(secretKeyStr.getBytes(), "AES");
			Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
			cipher.init(Cipher.ENCRYPT_MODE, secretKey);
			
			return Base64.getEncoder().encodeToString(cipher.doFinal(strToEncrypt.getBytes()));
		} catch (RuntimeException | NoSuchAlgorithmException | NoSuchPaddingException | InvalidKeyException 
				|IllegalBlockSizeException | BadPaddingException e) {
			throw new DatabaseSecurityException("Erro ao aplicar a criptografia: " + e.getMessage());
		} 
		
	}
	
	
	public String decrypt(String strToDecrypt) {
		
		try {
			SecretKeySpec secretKey = new SecretKeySpec(secretKeyStr.getBytes(), "AES");
			Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
			cipher.init(Cipher.DECRYPT_MODE, secretKey);
			
			return new String(cipher.doFinal(Base64.getDecoder().decode(strToDecrypt)));
		} catch (RuntimeException | NoSuchAlgorithmException | NoSuchPaddingException | InvalidKeyException 
				|IllegalBlockSizeException | BadPaddingException e) {
			throw new DatabaseSecurityException("Erro ao aplicar descriptografia: " + e.getMessage());
		} 
		
	}
	
}
