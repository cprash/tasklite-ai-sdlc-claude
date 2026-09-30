export type TaskStatus = "OPEN" | "COMPLETED";

export interface Task {
  id: number;
  title: string;
  status: TaskStatus;
  createdAt: string;
  updatedAt: string;
}
