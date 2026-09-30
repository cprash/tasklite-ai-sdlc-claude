import { z } from "zod";

export const createTaskSchema = z.object({
  title: z.string().trim().min(1, "title is required"),
});

export const updateTaskStatusSchema = z.object({
  status: z.enum(["OPEN", "COMPLETED"]),
});

export type CreateTaskInput = z.infer<typeof createTaskSchema>;
export type UpdateTaskStatusInput = z.infer<typeof updateTaskStatusSchema>;
