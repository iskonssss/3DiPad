// WhatsApp Business Cloud API — sends the "print ready" template message.
// Fully working; needs WHATSAPP_PHONE_NUMBER_ID + WHATSAPP_ACCESS_TOKEN in env
// and an APPROVED template (name/lang set in config.integrations.whatsapp).
//
// Business-initiated messages MUST use a pre-approved template. Create one in the
// Meta WhatsApp Manager, e.g. body: "Hi {{1}}, your 3D print is ready for pickup!"

export async function sendReady(cfg, job) {
  const wa = cfg.integrations.whatsapp;
  if (!wa?.enabled) return { ok: false, skipped: 'whatsapp disabled' };

  const phoneId = process.env.WHATSAPP_PHONE_NUMBER_ID;
  const token = process.env.WHATSAPP_ACCESS_TOKEN;
  if (!phoneId || !token) return { ok: false, error: 'missing WHATSAPP_* env' };

  const to = normalise(job.contact.phone);
  const body = {
    messaging_product: 'whatsapp',
    to,
    type: 'template',
    template: {
      name: wa.templateName,
      language: { code: wa.languageCode || 'en' },
      components: [
        { type: 'body', parameters: [{ type: 'text', text: job.contact.name.split(' ')[0] || 'there' }] },
      ],
    },
  };

  try {
    const r = await fetch(`https://graph.facebook.com/v20.0/${phoneId}/messages`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    const data = await r.json().catch(() => ({}));
    if (!r.ok) return { ok: false, error: data?.error?.message || `HTTP ${r.status}` };
    return { ok: true, id: data?.messages?.[0]?.id };
  } catch (e) {
    return { ok: false, error: String(e) };
  }
}

// Digits only, drop a leading 0, keep country code as given.
function normalise(phone) {
  return String(phone).replace(/[^\d]/g, '').replace(/^0+/, '');
}
