import { beforeEach, describe, expect, it, vi } from "vitest";
import request from "supertest";
import { Prisma } from "@prisma/client";

// EPMCDMETST-66640 — PATCH /api/tasks/:id (edit task title).
// The Prisma client is mocked so these tests exercise the HTTP, validation,
// and error-mapping layers deterministically, with no live database. The
// real-DB persistence check is covered by the Verify stage (Step 7).
vi.mock("../src/lib/prisma.js", () => ({
  prisma: { task: { update: vi.fn() } },
}));

import { createApp } from "../src/app.js";
import { prisma } from "../src/lib/prisma.js";

const app = createApp();
const update = prisma.task.update as unknown as ReturnType<typeof vi.fn>;

const updatedTask = {
  id: 1,
  title: "Renamed task",
  status: "OPEN",
  createdAt: new Date("2026-01-01T00:00:00.000Z").toISOString(),
  updatedAt: new Date("2026-01-02T00:00:00.000Z").toISOString(),
};

beforeEach(() => {
  vi.clearAllMocks();
});

describe("PATCH /api/tasks/:id (edit task title)", () => {
  it("AC1: a non-empty title is saved and returned → 200 (stored trimmed)", async () => {
    update.mockResolvedValueOnce(updatedTask);

    const res = await request(app).patch("/api/tasks/1").send({ title: "  Renamed task  " });

    expect(res.status).toBe(200);
    expect(res.body.title).toBe("Renamed task");
    expect(update).toHaveBeenCalledWith({ where: { id: 1 }, data: { title: "Renamed task" } });
  });

  it("AC2: unknown id → 404 and nothing persisted", async () => {
    update.mockRejectedValueOnce(
      new Prisma.PrismaClientKnownRequestError("Record to update not found", {
        code: "P2025",
        clientVersion: "test",
      }),
    );

    const res = await request(app).patch("/api/tasks/999").send({ title: "Whatever" });

    expect(res.status).toBe(404);
    expect(res.body).toEqual({ error: "Task not found" });
  });

  it("AC3: empty title → 400 and no write", async () => {
    const res = await request(app).patch("/api/tasks/1").send({ title: "" });

    expect(res.status).toBe(400);
    expect(update).not.toHaveBeenCalled();
  });

  it("AC3: whitespace-only title → 400 and no write", async () => {
    const res = await request(app).patch("/api/tasks/1").send({ title: "   " });

    expect(res.status).toBe(400);
    expect(update).not.toHaveBeenCalled();
  });

  it("edge: non-integer id → 404 before any DB call", async () => {
    const res = await request(app).patch("/api/tasks/abc").send({ title: "Valid title" });

    expect(res.status).toBe(404);
    expect(update).not.toHaveBeenCalled();
  });

  it("edge: title longer than 255 chars → 400 and no write", async () => {
    const res = await request(app)
      .patch("/api/tasks/1")
      .send({ title: "a".repeat(256) });

    expect(res.status).toBe(400);
    expect(update).not.toHaveBeenCalled();
  });
});
