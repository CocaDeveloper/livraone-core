export type ProjectStatus = "active" | "archived";

export type Project = {
  id: string;
  name: string;
  description?: string;
  status: ProjectStatus;
  createdAt: string;
  updatedAt: string;
};

const projects = new Map<string, Project>();

export function listProjects(): Project[] {
  return Array.from(projects.values()).sort((a, b) => b.createdAt.localeCompare(a.createdAt));
}

export function getProject(id: string): Project | null {
  return projects.get(id) ?? null;
}

export function createProject(input: { name: string; description?: string }): Project {
  const name = (input.name ?? "").trim();
  if (!name) {
    throw new Error("name_required");
  }

  const now = new Date().toISOString();
  const id = globalThis.crypto?.randomUUID ? globalThis.crypto.randomUUID() : `${Date.now()}-${Math.random()}`;

  const project: Project = {
    id,
    name,
    description: input.description?.trim() || undefined,
    status: "active",
    createdAt: now,
    updatedAt: now,
  };

  projects.set(id, project);
  return project;
}
