import { Router } from "express";
import { createTask, deleteTask, listTasks, updateTaskStatus } from "../controllers/tasks.controller.js";

export const tasksRouter = Router();

tasksRouter.get("/tasks", listTasks);
tasksRouter.post("/tasks", createTask);
tasksRouter.patch("/tasks/:id/status", updateTaskStatus);
tasksRouter.delete("/tasks/:id", deleteTask);
