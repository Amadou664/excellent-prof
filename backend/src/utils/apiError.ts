/**
 * Erreur applicative uniforme. Interceptee par src/middleware/errorHandler.ts et transformee
 * en `{ error: { code, message } }` avec le statut HTTP fourni.
 */
export class ApiError extends Error {
  status: number;
  code: string;

  constructor(status: number, code: string, message: string) {
    super(message);
    this.status = status;
    this.code = code;
    this.name = "ApiError";
  }

  static badRequest(message: string, code = "BAD_REQUEST") {
    return new ApiError(400, code, message);
  }

  static unauthorized(message = "Authentification requise", code = "UNAUTHORIZED") {
    return new ApiError(401, code, message);
  }

  static forbidden(message = "Acces refuse", code = "FORBIDDEN") {
    return new ApiError(403, code, message);
  }

  static notFound(message = "Ressource introuvable", code = "NOT_FOUND") {
    return new ApiError(404, code, message);
  }

  static conflict(message: string, code = "CONFLICT") {
    return new ApiError(409, code, message);
  }

  static internal(message = "Erreur interne du serveur", code = "INTERNAL_ERROR") {
    return new ApiError(500, code, message);
  }
}
