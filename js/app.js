/* InvenTec · Navegación e interacciones de la interfaz
   Evidencia GA6-220501096-AA4-EV03 */
'use strict';

const $ = (id) => document.getElementById(id);
const titles = {};
document.querySelectorAll('.screen[data-title]').forEach(s => { titles[s.id] = s.dataset.title; });

/* ---------- Mensajes breves de confirmación ---------- */
function toast(msg) {
  const t = $('toast');
  t.textContent = msg;
  t.setAttribute('role', 'status');
  t.classList.add('show');
  clearTimeout(window._tt);
  window._tt = setTimeout(() => t.classList.remove('show'), 2400);
}

/* ---------- Panel de notificaciones ---------- */
function toggleNotif(force) {
  const n = $('notif');
  const show = force !== undefined ? force : n.classList.contains('hidden');
  n.classList.toggle('hidden', !show);
  $('bell').setAttribute('aria-expanded', String(show));
}

/* ---------- Menú lateral (móvil y tablet) ---------- */
function toggleMenu(force) {
  const open = force !== undefined ? force : !document.body.classList.contains('menu-open');
  document.body.classList.toggle('menu-open', open);
  const b = $('menu-btn');
  b.setAttribute('aria-expanded', String(open));
  b.setAttribute('aria-label', open ? 'Cerrar menú' : 'Abrir menú');
}

/* ---------- Cambio de pantalla ---------- */
function go(id) {
  toggleNotif(false);
  toggleMenu(false);
  const login = $('login');
  const shell = $('shell');

  if (id === 'login') {
    shell.classList.add('hidden');
    login.style.display = 'flex';
    document.title = 'Iniciar sesión | InvenTec';
    history.replaceState(null, '', '#login');
    return;
  }

  login.style.display = 'none';
  shell.classList.remove('hidden');
  document.querySelectorAll('.screen').forEach(s => s.classList.toggle('active', s.id === id));

  const scr = $(id);
  const navKey = (scr && scr.dataset.nav) || id;
  $('page-title').textContent = titles[id] || '';
  document.title = (titles[id] || 'InvenTec') + ' | InvenTec';

  document.querySelectorAll('#nav a').forEach(a => {
    const active = a.dataset.nav === navKey;
    a.classList.toggle('active', active);
    if (active) a.setAttribute('aria-current', 'page'); else a.removeAttribute('aria-current');
  });

  const content = $('content');
  content.scrollTop = 0;
  content.focus({ preventScroll: true });
  history.replaceState(null, '', '#' + id);
}

/* ---------- Eventos ---------- */
document.addEventListener('click', (e) => {
  const g = e.target.closest('[data-go]');
  const t = e.target.closest('[data-toast]');

  if (t && !g) { toast(t.dataset.toast); return; }
  if (g) {
    e.preventDefault();
    if (g.dataset.toast) toast(g.dataset.toast);
    go(g.dataset.go);
    return;
  }
  if (!e.target.closest('#notif') && !e.target.closest('#bell')) toggleNotif(false);
});

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') { toggleNotif(false); toggleMenu(false); }
  if ((e.key === 'Enter' || e.key === ' ') && e.target.matches('[role="button"][data-go]')) {
    e.preventDefault();
    go(e.target.dataset.go);
  }
});

window.addEventListener('load', () => {
  const h = location.hash.replace('#', '');
  go(h && $(h) ? h : 'login');
});
