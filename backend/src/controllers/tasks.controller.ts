import type { NextFunction, Request, Response } from "express";
import { Prisma } from "@prisma/client";
import { prisma } from "../lib/prisma.js";
import { createTaskSchema, updateTaskStatusSchema } from "../validators/task.validators.js";
import { HttpError } from "../utils/httpError.js";

export async function listTasks(_req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const tasks = await prisma.task.findMany({
      orderBy: { createdAt: "desc" },
    });
    res.json(tasks);
  } catch (error) {
    next(error);
  }
}

export async function createTask(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const parsed = createTaskSchema.safeParse(req.body);
    if (!parsed.success) {
      throw new HttpError(400, "title is required");
    }

    const task = await prisma.task.create({
      data: { title: parsed.data.title },
    });
    res.status(201).json(task);
  } catch (error) {
    next(error);
  }
}

export async function updateTaskStatus(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) {
      throw new HttpError(404, "Task not found");
    }

    const parsed = updateTaskStatusSchema.safeParse(req.body);
    if (!parsed.success) {
      throw new HttpError(400, "status must be OPEN or COMPLETED");
    }

    const task = await prisma.task.update({
      where: { id },
      data: { status: parsed.data.status },
    });
    res.json(task);
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2025") {
      next(new HttpError(404, "Task not found"));
      return;
    }
    next(error);
  }
}

export async function deleteTask(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) {
      throw new HttpError(404, "Task not found");
    }

    await prisma.task.delete({ where: { id } });
    res.status(204).send();
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2025") {
      next(new HttpError(404, "Task not found"));
      return;
    }
    next(error);
  }
}
