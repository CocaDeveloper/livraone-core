"use client";

import { useEffect, useMemo, useState } from "react";

type Project = {
  id: string;
  name: string;
  description?: string;
  status: "active" | "archived";
  createdAt: string;
  updatedAt: string;
};

export default function ProjectsClient() {
  const [projects, setProjects] = useState<Project[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function refresh() {
    setError(null);
    const res = await fetch("/api/projects", { cache: "no-store" });
    if (!res.ok) {
      setError(`list_failed:${res.status}`);
      setProjects([]);
      return;
    }
    const data = await res.json();
    setProjects(data.items ?? []);
  }

  useEffect(() => {
    void refresh();
  }, []);

  const count = useMemo(() => projects?.length ?? 0, [projects]);

  async function onCreate() {
    const name = window.prompt("Project name?") ?? "";
    if (!name.trim()) return;

    const res = await fetch("/api/projects", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ name }),
    });

    if (!res.ok) {
      setError(`create_failed:${res.status}`);
      return;
    }

    await refresh();
  }

  return (
    <section>
      <header style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <div>
          <h1>Projects</h1>
          <p style={{ opacity: 0.8 }}>{count} total</p>
        </div>
        <button onClick={onCreate}>Create</button>
      </header>

      {error ? <p style={{ color: "crimson" }}>{error}</p> : null}

      <ul>
        {(projects ?? []).map((p) => (
          <li key={p.id}>
            <a href={`/projects/${p.id}`}>{p.name}</a>
            {p.description ? <span style={{ opacity: 0.7 }}> {p.description}</span> : null}
          </li>
        ))}
      </ul>

      {projects === null ? <p>Loading...</p> : null}
      {projects !== null && projects.length === 0 ? <p>No projects yet.</p> : null}
    </section>
  );
}
