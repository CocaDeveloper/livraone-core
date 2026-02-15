"use client";

import { useEffect, useState } from "react";

type Project = {
  id: string;
  name: string;
  description?: string;
  status: "active" | "archived";
  createdAt: string;
  updatedAt: string;
};

export default function ProjectDetailPage({ params }: { params: { id: string } }) {
  const [project, setProject] = useState<Project | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    async function run() {
      const res = await fetch(`/api/projects/${params.id}`, { cache: "no-store" });
      if (!res.ok) {
        if (!cancelled) setError(`load_failed:${res.status}`);
        return;
      }
      const data = await res.json();
      if (!cancelled) setProject(data.item ?? null);
    }
    void run();
    return () => {
      cancelled = true;
    };
  }, [params.id]);

  if (error) return <p style={{ color: "crimson" }}>{error}</p>;
  if (!project) return <p>Loading...</p>;

  return (
    <section>
      <p>
        <a href="/projects">Back</a>
      </p>
      <h1>{project.name}</h1>
      <p style={{ opacity: 0.8 }}>{project.description ?? "(no description)"}</p>
      <dl>
        <dt>Status</dt>
        <dd>{project.status}</dd>
        <dt>Created</dt>
        <dd>{project.createdAt}</dd>
        <dt>Updated</dt>
        <dd>{project.updatedAt}</dd>
        <dt>ID</dt>
        <dd>{project.id}</dd>
      </dl>
    </section>
  );
}
