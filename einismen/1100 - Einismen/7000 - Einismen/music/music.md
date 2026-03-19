---
uid: c0172503-5002-4156-853d-767243728431
created: 2025-07-04T11:12:49+02:00
modified: 2025-07-04T11:12:52+02:00
---
```dataviewjs
const folder = dv.current().file.folder;
const currentFile = dv.current().file.path;
const pages = dv.pages(`"${folder}"`).where(p => p.file.path !== currentFile);

// Funktion för att formatera "tid sedan"
function timeAgo(date) {
  const seconds = (Date.now() - date.valueOf()) / 1000;
  if (seconds < 60) return `${Math.floor(seconds)} sekunder sedan`;
  const minutes = seconds / 60;
  if (minutes < 60) return `${Math.floor(minutes)} minuter sedan`;
  const hours = minutes / 60;
  if (hours < 24) return `${Math.floor(hours)} timmar sedan`;
  const days = hours / 24;
  if (days < 7) return `${Math.floor(days)} dagar sedan`;
  const weeks = days / 7;
  if (weeks < 52) return `${Math.floor(weeks)} veckor sedan`;
  const years = weeks / 52;
  return `${Math.floor(years)} år sedan`;
}

dv.table(
  ["Namn", "Skapad"],
  pages.map(p => [
    dv.fileLink(p.file.path),
    timeAgo(p.file.ctime)
  ])
);
```