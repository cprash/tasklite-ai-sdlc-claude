import type { NextFunction, Request, Response } from "express";
import { HttpError } from "../utils/httpError.js";

// Express recognizes this as error-handling middleware because it takes 4 args
export function errorHandler(error: unknown, _req: Request, res: Response, _next: NextFunction): void {
  if (error instanceof HttpError) {
    res.status(error.statusCode).json({ error: error.message });
    return;
  }

  console.error(error);
  res.status(500).json({ error: "Internal server error" });
}
