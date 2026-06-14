// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Trix and ActionText are loaded via CDN in the layout

function initPublicSite() {
  const revealItems = document.querySelectorAll("[data-reveal]");
  if ("IntersectionObserver" in window && revealItems.length) {
    document.documentElement.classList.add("tom-reveal-enabled");
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.14, rootMargin: "0px 0px -40px 0px" });

    revealItems.forEach((item) => observer.observe(item));
  } else {
    revealItems.forEach((item) => item.classList.add("is-visible"));
  }

  const backTop = document.querySelector("[data-back-to-top]");
  if (backTop) {
    const toggleBackTop = () => backTop.classList.toggle("is-visible", window.scrollY > 500);
    toggleBackTop();
    window.addEventListener("scroll", toggleBackTop, { passive: true });
    backTop.addEventListener("click", () => window.scrollTo({ top: 0, behavior: "smooth" }));
  }

  document.querySelectorAll("[data-copy-text]").forEach((button) => {
    if (button.dataset.copyBound) return;
    button.dataset.copyBound = "true";
    button.addEventListener("click", async () => {
      const original = button.textContent;
      try {
        if (navigator.clipboard && window.isSecureContext) {
          await navigator.clipboard.writeText(button.dataset.copyText);
        } else {
          const textarea = document.createElement("textarea");
          textarea.value = button.dataset.copyText;
          textarea.setAttribute("readonly", "");
          textarea.style.position = "fixed";
          textarea.style.top = "-9999px";
          document.body.appendChild(textarea);
          textarea.select();
          document.execCommand("copy");
          textarea.remove();
        }
        button.textContent = "Copied";
        setTimeout(() => { button.textContent = original; }, 1600);
      } catch (_error) {
        button.textContent = "Copy failed";
        setTimeout(() => { button.textContent = original; }, 1600);
      }
    });
  });

  document.querySelectorAll("[data-filter-group]").forEach((group) => {
    if (group.dataset.filterBound) return;
    group.dataset.filterBound = "true";

    const buttons = group.querySelectorAll("[data-filter-button]");
    const items = group.querySelectorAll("[data-filter-item]");
    const empty = group.querySelector("[data-filter-empty]");

    function applyFilter(filter) {
      let visibleCount = 0;

      items.forEach((item) => {
        const filters = (item.dataset.filterItem || "").split(/\s+/);
        const visible = filter === "all" || filters.includes(filter);
        item.hidden = !visible;
        if (visible) visibleCount += 1;
      });

      buttons.forEach((button) => {
        const active = button.dataset.filterButton === filter;
        button.classList.toggle("tom-filter-active", active);
        button.setAttribute("aria-selected", active ? "true" : "false");
      });

      if (empty) empty.hidden = visibleCount > 0;
    }

    buttons.forEach((button) => {
      button.addEventListener("click", () => applyFilter(button.dataset.filterButton));
    });

    applyFilter(group.dataset.defaultFilter || "all");
  });

  document.querySelectorAll("[data-tabs]").forEach((tabs) => {
    if (tabs.dataset.tabsBound) return;
    tabs.dataset.tabsBound = "true";

    const buttons = tabs.querySelectorAll("[data-tab-button]");
    const panels = tabs.querySelectorAll("[data-tab-panel]");

    function activate(tabName) {
      buttons.forEach((button) => {
        const active = button.dataset.tabButton === tabName;
        button.classList.toggle("tom-tab-active", active);
        button.setAttribute("aria-selected", active ? "true" : "false");
      });

      panels.forEach((panel) => {
        const active = panel.dataset.tabPanel === tabName;
        panel.hidden = !active;
        panel.classList.toggle("is-active", active);
      });
    }

    buttons.forEach((button) => {
      button.addEventListener("click", () => activate(button.dataset.tabButton));
    });

    activate(tabs.dataset.defaultTab || buttons[0]?.dataset.tabButton || "");
  });

  const teamModal = document.querySelector("[data-team-modal]");
  if (teamModal && !teamModal.dataset.modalBound) {
    teamModal.dataset.modalBound = "true";

    const modalImage = teamModal.querySelector("[data-team-modal-image]");
    const modalName = teamModal.querySelector("[data-team-modal-name]");
    const modalRole = teamModal.querySelector("[data-team-modal-role]");
    const modalBio = teamModal.querySelector("[data-team-modal-bio]");
    const modalFocus = teamModal.querySelector("[data-team-modal-focus]");
    const closeButton = teamModal.querySelector("[data-team-modal-close]");

    function closeModal() {
      if (typeof teamModal.close === "function") {
        teamModal.close();
      } else {
        teamModal.hidden = true;
      }
    }

    document.querySelectorAll("[data-team-card]").forEach((card) => {
      if (card.dataset.teamBound) return;
      card.dataset.teamBound = "true";

      card.addEventListener("click", () => {
        modalImage.src = card.dataset.teamImage || "";
        modalImage.alt = card.dataset.teamName || "Team member";
        modalName.textContent = card.dataset.teamName || "";
        modalRole.textContent = card.dataset.teamRole || "";
        modalBio.textContent = card.dataset.teamBio || "";
        modalFocus.textContent = card.dataset.teamFocus || "";

        if (typeof teamModal.showModal === "function") {
          teamModal.showModal();
        } else {
          teamModal.hidden = false;
        }
      });
    });

    if (closeButton) closeButton.addEventListener("click", closeModal);
    teamModal.addEventListener("click", (event) => {
      const dialogBox = teamModal.getBoundingClientRect();
      const clickedBackdrop =
        event.clientX < dialogBox.left ||
        event.clientX > dialogBox.right ||
        event.clientY < dialogBox.top ||
        event.clientY > dialogBox.bottom;

      if (clickedBackdrop) closeModal();
    });
  }

  const globalModal = document.querySelector("[data-global-modal]");
  if (globalModal) {
    const openGlobalModal = () => {
      if (globalModal.open) return;

      if (typeof globalModal.showModal === "function") {
        try {
          globalModal.showModal();
          return;
        } catch (_error) {
          globalModal.setAttribute("open", "");
        }
      } else {
        globalModal.hidden = false;
      }
    };

    setTimeout(openGlobalModal, 100);

    if (globalModal.dataset.modalBound) return;
    globalModal.dataset.modalBound = "true";

    const closeBtn = globalModal.querySelector("[data-global-modal-close]");

    function closeGlobalModal() {
      if (typeof globalModal.close === "function") {
        globalModal.close();
      } else {
        globalModal.remove();
      }
    }

    if (closeBtn) closeBtn.addEventListener("click", closeGlobalModal);

    globalModal.addEventListener("click", (event) => {
      if (event.target === globalModal) {
        closeGlobalModal();
        return;
      }

      const dialogBox = globalModal.getBoundingClientRect();
      const clickedBackdrop =
        event.clientX < dialogBox.left ||
        event.clientX > dialogBox.right ||
        event.clientY < dialogBox.top ||
        event.clientY > dialogBox.bottom;

      if (clickedBackdrop) closeGlobalModal();
    });
  }
}

document.addEventListener("turbo:before-cache", () => {
  document.querySelectorAll("[data-global-modal]").forEach((globalModal) => {
    if (typeof globalModal.close === "function") {
      if (globalModal.open) globalModal.close();
    } else {
      globalModal.removeAttribute("open");
      globalModal.remove();
    }
  });
});

document.addEventListener("turbo:load", initPublicSite);
document.addEventListener("DOMContentLoaded", initPublicSite);
