---
created: 2025-05-14T23:06:32+02:00
modified: 2025-05-14T23:06:33+02:00
uid: 31668d10-5d52-4146-a8d7-e71330cc3461
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