// Google Drive upload of the finished .gcode.
//
// Config-gated. Uses `googleapis` if installed + a service-account key in
// GOOGLE_APPLICATION_CREDENTIALS (share the target Drive folder with that
// service account's email). If the dependency isn't present it degrades to a
// no-op so the booth still runs — every file is always saved locally regardless.
//
//   npm install googleapis      # to enable

import fs from 'node:fs';
import path from 'node:path';

let driveClient = null;
let triedInit = false;

async function getClient() {
  if (triedInit) return driveClient;
  triedInit = true;
  try {
    const { google } = await import('googleapis');
    const auth = new google.auth.GoogleAuth({ scopes: ['https://www.googleapis.com/auth/drive.file'] });
    driveClient = google.drive({ version: 'v3', auth });
  } catch {
    driveClient = null; // googleapis not installed / no creds
  }
  return driveClient;
}

export async function uploadGcode(cfg, filePath) {
  const d = cfg.integrations.drive;
  if (!d?.enabled) return { ok: false, skipped: 'drive disabled' };
  const drive = await getClient();
  if (!drive) return { ok: false, error: 'googleapis not installed or no credentials' };

  try {
    const res = await drive.files.create({
      requestBody: {
        name: path.basename(filePath),
        parents: d.folderId ? [d.folderId] : undefined,
      },
      media: { mimeType: 'text/plain', body: fs.createReadStream(filePath) },
      fields: 'id, webViewLink',
    });
    return { ok: true, id: res.data.id, link: res.data.webViewLink };
  } catch (e) {
    return { ok: false, error: String(e) };
  }
}
