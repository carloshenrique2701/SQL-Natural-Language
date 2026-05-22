package com.sql_engine.v_1_0.services;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class AiSqlGeneratorService {
	
	@Autowired
	private GenAiService genAiService;

	public String generateSql(String userQuery, String schema, String dialect, String model) {
		
		String prompt = """
				
				Você é um especialista em SQL.
				Banco de dados: %s
				Data atual: %s
				
				Schema do banco:
				%s
				
				Instrução: converta a pergunta do usuário em um SQL SELECT que possa responder-la.
				ex: 'Quantos funcionários eu tenho no total?' retorno: 'SELECT count(id) FROM tb_sellers;'
				
				Se a pergunta for muito genérica, como 'Me mostre os funcionários', retorne um SQL que limite o número de resultados em no máximo 20, 
				como 'SELECT * FROM tb_sellers LIMIT 20;'

				Se a pergunta não for compreendida, use de um select para "printar" a mensagem (se possível, diga o motivo):
				SELECT 'Não consegui compreender sua pergunta pois {MOTIVO}, pode refazê-la?' AS Resultado;
				
				Seu retorno deve conter somente a query conforme o exemplo, sem explicações ou markdown.

				Pergunta: %s
										
				""".formatted(dialect, LocalDate.now(), schema, userQuery);
		
		return genAiService.apiReq(prompt, model);
		
	}
	
	public String generateHtml(List<Map<String, Object>> result, String userQuery, String model) {
		
		String prompt = """
				
				Você é um especialista em HTML.
				Data atual: %s
				Seu trabalho é converter o resultado de uma query SQL em um formato HTML amigável para responder a pergunta de um usuário.
				
				Exemplo: SELECT COUNT(*) FROM tb_sellers;
				Resultado: 100
				Pergunta: Quantos funcionários eu tenho no total?
				Seu retorno deve ser: <p>Você tem um total de 100 funcionários.</p>
				
				Se a pergunta não for compreendida, retorne: <p>Não entendi sua pergunta, pode repetir?</p>
				
				Retorne SOMENTE o HTML, sem explicações ou markdown. Caso necessário, use CSS in-line para ajustar a estilização (em caso de tabelas, por exemplo), opte por cores escuras, principalmente: #28a05a e #161b22.
				
				Pergunta: %s
				resposta: %s
				
				""".formatted(LocalDate.now(), userQuery, result);
		
		return genAiService.apiReq(prompt, model);
		
	}
	
}
