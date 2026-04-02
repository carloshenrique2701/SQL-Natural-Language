package com.sql_natural_laguage_0.SNAPSHOT.services;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class AiSqlGeneratorService {
	
	@Autowired
	private GenAiService genAiService;

	public String generateSql(String userQuery, String schema, String dialect) {
		
		String prompt = """
				
				Você é um especialista em SQL.
				Banco de dados: %s
				Data atual: %s
				Schema do banco:
				%s
				
				Instrução: converta a pergunta do usuário em um SQL SELECT que possa responder-la.
				ex: 'Quantos funcionários eu tenho no total?' retorno: 'SELECT count(id) FROM tb_sellers;'
				
				Seu retorno deve conter somente a query conforme o exemplo, sem explicações ou markdown.

				Pergunta: %s
										
				""".formatted(dialect, LocalDate.now(), schema, userQuery);
		
		return genAiService.apiReq(prompt);
		
	}
	
	public String generateHtml(List<Map<String, Object>> result, String userQuery) {
		
		String prompt = """
				
				Você é um especialista em HTML.
				Data atual: %s
				Seu trabalho é converter o resultado de uma query SQL em um formato HTML amigável para responder a pergunta de um usuário.
				
				Exemplo: SELECT COUNT(*) FROM tb_sellers;
				Resultado: 100
				Pergunta: Quantos funcionários eu tenho no total?
				Seu retorno deve ser: <p>Você tem um total de 100 funcionários.</p>
				
				Retorne somente o HTML, sem explicações ou markdown.
				
				Pergunta: %s
				
				""".formatted(LocalDate.now(), userQuery, result);
		
		return genAiService.apiReq(prompt);
		
	}
	
}
