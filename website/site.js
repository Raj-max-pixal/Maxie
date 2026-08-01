const root = document.documentElement;
const loader = document.querySelector("[data-loader]");
const themeToggle = document.querySelector("[data-theme-toggle]");
const modal = document.querySelector("[data-shot-modal]");
const modalTitle = document.querySelector("[data-modal-title]");
const modalPreview = document.querySelector("[data-modal-preview]");
const modalClose = document.querySelector("[data-modal-close]");

const savedTheme = localStorage.getItem("maxie-site-theme");
if (savedTheme) root.dataset.theme = savedTheme;

window.addEventListener("load", () => {
  window.setTimeout(() => loader?.classList.add("is-hidden"), 450);
});

themeToggle?.addEventListener("click", () => {
  const nextTheme = root.dataset.theme === "light" ? "dark" : "light";
  if (nextTheme === "dark") root.removeAttribute("data-theme");
  else root.dataset.theme = "light";
  localStorage.setItem("maxie-site-theme", nextTheme);
});

const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add("is-visible");
      revealObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.15 });

document.querySelectorAll(".reveal").forEach((element) => revealObserver.observe(element));

document.querySelectorAll("[data-shot]").forEach((button) => {
  button.addEventListener("click", () => {
    const title = button.dataset.shot || "MAXie Preview";
    modalTitle.textContent = title;
    modalPreview.className = "modal-preview";
    modalPreview.classList.add(`${title.toLowerCase().replaceAll(" ", "-")}-modal`);
    if (typeof modal.showModal === "function") modal.showModal();
  });
});

modalClose?.addEventListener("click", () => modal.close());

modal?.addEventListener("click", (event) => {
  const rect = modal.getBoundingClientRect();
  const clickedOutside =
    event.clientX < rect.left ||
    event.clientX > rect.right ||
    event.clientY < rect.top ||
    event.clientY > rect.bottom;
  if (clickedOutside) modal.close();
});
