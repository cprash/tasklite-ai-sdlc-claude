import cors from "cors";
import express from "express";
import { errorHandler } from "./middleware/errorHandler.js";
import { healthRouter } from "./routes/health.routes.js";
import { tasksRouter } from "./routes/tasks.routes.js";

export function createApp() {
  const app = express();

  app.use(cors({ origin: "http://localhost:5173" }));
  app.use(express.json());

  app.use("/api", healthRouter);
  app.use("/api", tasksRouter);

  app.use(errorHandler);

  return app;
}
