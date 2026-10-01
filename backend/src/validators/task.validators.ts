import { z } from "zod";

export const createTaskSchema = z.object({
  title: z.string().trim().min(1, "title is required"),
});

export const updateTaskStatusSchema = z.object({
  status: z.enum(["OPEN", "COMPLETED"]),
});

// EPMCDMETST-66640: a title edit must be a non-empty, non-whitespace string.
// .trim() normalizes the stored value; .max(255) is an interim cap pending
// product confirmation (see docs/EPMCDMETST-66640/architecture.md).
export const updateTaskTitleSchema = z.object({
  title: z
    .string()
    .trim()
    .min(1, "title is required")
    .max(255, "title must be at most 255 characters"),
});

export type CreateTaskInput = z.infer<typeof createTaskSchema>;
export type UpdateTaskStatusInput = z.infer<typeof updateTaskStatusSchema>;
export type UpdateTaskTitleInput = z.infer<typeof updateTaskTitleSchema>;
