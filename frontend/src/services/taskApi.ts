import type { Task, TaskStatus } from "../types/task";

const API_BASE_URL = "http://localhost:3000/api";

async function handleResponse<T>(response: Response): Promise<T> {
  if (!response.ok) {
    const body = (await response.json().catch(() => null)) as { error?: string } | null;
    throw new Error(body?.error ?? `Request failed with status ${response.status}`);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return (await response.json()) as T;
}

export function fetchTasks(): Promise<Task[]> {
  return fetch(`${API_BASE_URL}/tasks`).then((res) => handleResponse<Task[]>(res));
}

export function createTask(title: string): Promise<Task> {
  return fetch(`${API_BASE_URL}/tasks`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title }),
  }).then((res) => handleResponse<Task>(res));
}

export function updateTaskStatus(id: number, status: TaskStatus): Promise<Task> {
  return fetch(`${API_BASE_URL}/tasks/${id}/status`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status }),
  }).then((res) => handleResponse<Task>(res));
}

export function deleteTask(id: number): Promise<void> {
  return fetch(`${API_BASE_URL}/tasks/${id}`, {
    method: "DELETE",
  }).then((res) => handleResponse<void>(res));
}
