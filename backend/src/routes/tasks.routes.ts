import { Router } from "express";
import { createTask, deleteTask, listTasks, updateTaskStatus, updateTaskTitle } from "../controllers/tasks.controller.js";

export const tasksRouter = Router();

tasksRouter.get("/tasks", listTasks);
tasksRouter.post("/tasks", createTask);
tasksRouter.patch("/tasks/:id/status", updateTaskStatus);
tasksRouter.patch("/tasks/:id", updateTaskTitle);
tasksRouter.delete("/tasks/:id", deleteTask);
