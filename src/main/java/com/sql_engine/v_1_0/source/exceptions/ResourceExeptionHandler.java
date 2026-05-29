package com.sql_engine.v_1_0.source.exceptions;

import java.time.Instant;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.multipart.MultipartException;

import java.sql.SQLException;

import org.springframework.dao.DataAccessException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.MethodArgumentNotValidException;

import com.fasterxml.jackson.core.JsonProcessingException;
import io.jsonwebtoken.ExpiredJwtException;
import jakarta.validation.ConstraintViolationException;

import com.sql_engine.v_1_0.services.exceptions.DatabaseException;
import com.sql_engine.v_1_0.services.exceptions.ai.AiConsultationException;
import com.sql_engine.v_1_0.services.exceptions.ai.DatabaseSecurityException;
import com.sql_engine.v_1_0.services.exceptions.users.InvalidCredentialsException;
import com.sql_engine.v_1_0.services.exceptions.users.ResourceNotFoundException;

import jakarta.servlet.http.HttpServletRequest;

@ControllerAdvice
public class ResourceExeptionHandler {
	
	@ExceptionHandler(InvalidCredentialsException.class)
	public ResponseEntity<StandardError> handleInvalidCredentials(InvalidCredentialsException e, HttpServletRequest request) {
		String error = "Invalid credentials.";
		HttpStatus status = HttpStatus.UNAUTHORIZED;
		return buildErrorResponse(status, error, e.getMessage(), request);
	}

	@ExceptionHandler(HttpMessageNotReadableException.class)
	public ResponseEntity<StandardError> handleHttpMessageNotReadable(HttpMessageNotReadableException e, HttpServletRequest request) {
		String error = "Malformed request.";
		HttpStatus status = HttpStatus.BAD_REQUEST;
		String message = "The request body is invalid or malformed. Check the JSON syntax and field names.";
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(MissingServletRequestParameterException.class)
	public ResponseEntity<StandardError> handleMissingServletRequestParameter(MissingServletRequestParameterException e, HttpServletRequest request) {
		String error = "Missing request parameter.";
		HttpStatus status = HttpStatus.BAD_REQUEST;
		String message = String.format("Required request parameter '%s' is missing.", e.getParameterName());
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(HttpRequestMethodNotSupportedException.class)
	public ResponseEntity<StandardError> handleMethodNotSupported(HttpRequestMethodNotSupportedException e, HttpServletRequest request) {
		String error = "Method not allowed.";
		HttpStatus status = HttpStatus.METHOD_NOT_ALLOWED;
		Set<HttpMethod> supported = e.getSupportedHttpMethods();
		String supportedMethods = supported == null || supported.isEmpty()
			? "none"
			: supported.stream().map(HttpMethod::name).collect(Collectors.joining(", "));
		String message = String.format("%s method is not supported for this request. Supported methods: %s.", e.getMethod(), supportedMethods);
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(HttpMediaTypeNotSupportedException.class)
	public ResponseEntity<StandardError> handleHttpMediaTypeNotSupported(HttpMediaTypeNotSupportedException e, HttpServletRequest request) {
		String error = "Unsupported media type.";
		HttpStatus status = HttpStatus.UNSUPPORTED_MEDIA_TYPE;
		String supportedMedia = e.getSupportedMediaTypes() == null || e.getSupportedMediaTypes().isEmpty()
			? "none"
			: e.getSupportedMediaTypes().stream().map(Object::toString).collect(Collectors.joining(", "));
		String message = String.format("Content type '%s' is not supported. Supported types: %s.", e.getContentType(), supportedMedia);
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(MultipartException.class)
	public ResponseEntity<StandardError> handleMultipartException(MultipartException e, HttpServletRequest request) {
		String error = "Multipart request error.";
		HttpStatus status = HttpStatus.BAD_REQUEST;
		String message = "The multipart request is invalid or could not be parsed.";
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(MaxUploadSizeExceededException.class)
	public ResponseEntity<StandardError> handleMaxUploadSizeExceeded(MaxUploadSizeExceededException e, HttpServletRequest request) {
		String error = "Payload too large.";
		HttpStatus status = HttpStatus.PAYLOAD_TOO_LARGE;
		String message = "Uploaded file size exceeds the maximum allowed limit.";
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(ConstraintViolationException.class)
	public ResponseEntity<StandardError> handleConstraintViolation(ConstraintViolationException e, HttpServletRequest request) {
		String error = "Validation failed.";
		HttpStatus status = HttpStatus.BAD_REQUEST;
		String message = e.getMessage() != null ? e.getMessage() : "Request validation failed.";
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(JsonProcessingException.class)
	public ResponseEntity<StandardError> handleJsonProcessingException(JsonProcessingException e, HttpServletRequest request) {
		String error = "Invalid JSON content.";
		HttpStatus status = HttpStatus.BAD_REQUEST;
		String message = e.getOriginalMessage() != null ? e.getOriginalMessage() : "Failed to parse JSON.";
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(MethodArgumentNotValidException.class)
	public ResponseEntity<StandardError> handleMethodArgumentNotValid(MethodArgumentNotValidException e, HttpServletRequest request) {
		String error = "Validation failed.";
		HttpStatus status = HttpStatus.BAD_REQUEST;
		String message = e.getBindingResult() != null && e.getBindingResult().getFieldError() != null
			? String.format("%s: %s", e.getBindingResult().getFieldError().getField(), e.getBindingResult().getFieldError().getDefaultMessage())
			: "One or more fields are invalid.";
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(AccessDeniedException.class)
	public ResponseEntity<StandardError> handleAccessDenied(AccessDeniedException e, HttpServletRequest request) {
		String error = "Access denied.";
		HttpStatus status = HttpStatus.FORBIDDEN;
		String message = e.getMessage() != null ? e.getMessage() : "You do not have permission to access this resource.";
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(DataIntegrityViolationException.class)
	public ResponseEntity<StandardError> handleDataIntegrityViolation(DataIntegrityViolationException e, HttpServletRequest request) {
		String error = "Data integrity violation.";
		HttpStatus status = HttpStatus.CONFLICT;
		String message = e.getMostSpecificCause() != null ? e.getMostSpecificCause().getMessage() : e.getMessage();
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(DataAccessException.class)
	public ResponseEntity<StandardError> handleDataAccessException(DataAccessException e, HttpServletRequest request) {
		String error = "Database access error.";
		HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
		String message = e.getMostSpecificCause() != null ? e.getMostSpecificCause().getMessage() : e.getMessage();
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(SQLException.class)
	public ResponseEntity<StandardError> handleSQLException(SQLException e, HttpServletRequest request) {
		String error = "SQL error.";
		HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
		String message = e.getMessage() != null ? e.getMessage() : "A database error occurred.";
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(UsernameNotFoundException.class)
	public ResponseEntity<StandardError> handleUsernameNotFound(UsernameNotFoundException e, HttpServletRequest request) {
		String error = "Authentication failed.";
		HttpStatus status = HttpStatus.UNAUTHORIZED;
		String message = "Invalid username or password.";
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(ExpiredJwtException.class)
	public ResponseEntity<StandardError> handleExpiredJwt(ExpiredJwtException e, HttpServletRequest request) {
		String error = "Token expired.";
		HttpStatus status = HttpStatus.UNAUTHORIZED;
		String message = e.getMessage() != null ? e.getMessage() : "The authentication token has expired.";
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(NullPointerException.class)
	public ResponseEntity<StandardError> handleNullPointerException(NullPointerException e, HttpServletRequest request) {
		String error = "Unexpected error.";
		HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
		String message = "An unexpected null value was encountered.";
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(IllegalStateException.class)
	public ResponseEntity<StandardError> handleIllegalStateException(IllegalStateException e, HttpServletRequest request) {
		String error = "Application state error.";
		HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
		String message = e.getMessage() != null ? e.getMessage() : "The application is in an invalid state.";
		return buildErrorResponse(status, error, message, request);
	}

	@ExceptionHandler(ResourceNotFoundException.class)
	public ResponseEntity<StandardError> handleResourceNotFound(ResourceNotFoundException e, HttpServletRequest request) {
		String error = "Resource not found.";
		HttpStatus status = HttpStatus.NOT_FOUND;
		return buildErrorResponse(status, error, e.getMessage(), request);
	}
	
	@ExceptionHandler(AiConsultationException.class)
	public ResponseEntity<StandardError> handleAiConsultationException(AiConsultationException e, HttpServletRequest request) {
		String error = "AI consultation error.";
		HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
		return buildErrorResponse(status, error, e.getMessage(), request);
	}
	
	@ExceptionHandler(DatabaseSecurityException.class)
	public ResponseEntity<StandardError> handleDatabaseSecurityException(DatabaseSecurityException e, HttpServletRequest request) {
		String error = "Database security error.";
		HttpStatus status = HttpStatus.FORBIDDEN;
		return buildErrorResponse(status, error, e.getMessage(), request);
	}
	
	@ExceptionHandler(DatabaseException.class)
	public ResponseEntity<StandardError> handleDatabaseException(DatabaseException e, HttpServletRequest request) {
		String error = "Database error.";
		HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
		return buildErrorResponse(status, error, e.getMessage(), request);
	}

	private ResponseEntity<StandardError> buildErrorResponse(HttpStatus status, String error, String message, HttpServletRequest request) {
		StandardError err = new StandardError(Instant.now(), status.value(), error, message, request.getRequestURI());
		return ResponseEntity.status(status).body(err);
	}

}
