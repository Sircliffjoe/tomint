// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Trix and ActionText are loaded via CDN in the layout

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/service-worker.js").catch(() => {});
  });
}

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

  document.querySelectorAll("[data-team-popup-open]").forEach((trigger) => {
    if (trigger.dataset.teamPopupBound) return;
    trigger.dataset.teamPopupBound = "true";

    trigger.addEventListener("click", (event) => {
      const popup = document.getElementById(trigger.dataset.teamPopupOpen);
      if (!popup) return;

      event.preventDefault();
      document.querySelectorAll(".tom-team-popup.is-open").forEach((openPopup) => {
        openPopup.classList.remove("is-open");
      });
      popup.classList.add("is-open");
      document.body.classList.add("tom-modal-open");
      history.replaceState(null, "", `#${popup.id}`);
    });
  });

  document.querySelectorAll("[data-team-popup-close]").forEach((trigger) => {
    if (trigger.dataset.teamPopupCloseBound) return;
    trigger.dataset.teamPopupCloseBound = "true";

    trigger.addEventListener("click", (event) => {
      event.preventDefault();
      document.querySelectorAll(".tom-team-popup.is-open").forEach((popup) => {
        popup.classList.remove("is-open");
      });
      document.body.classList.remove("tom-modal-open");
      history.replaceState(null, "", "#leadership");
    });
  });

  document.querySelectorAll("[data-camp-details]").forEach((campDetails) => {
    if (campDetails.dataset.campDetailsBound) return;
    campDetails.dataset.campDetailsBound = "true";

    const modal = campDetails.querySelector("[data-camp-modal]");
    if (!modal) return;

    const closeButton = modal.querySelector("[data-camp-modal-close]");
    const image = modal.querySelector("[data-camp-modal-image]");
    const placeholder = modal.querySelector("[data-camp-modal-placeholder]");
    const state = modal.querySelector("[data-camp-modal-state]");
    const areas = modal.querySelector("[data-camp-modal-areas]");
    const switcher = modal.querySelector("[data-camp-modal-switcher]");
    const previousButton = modal.querySelector("[data-camp-modal-prev]");
    const nextButton = modal.querySelector("[data-camp-modal-next]");
    const count = modal.querySelector("[data-camp-modal-count]");
    const notes = modal.querySelector("[data-camp-modal-notes]");
    const link = modal.querySelector("[data-camp-modal-link]");
    let activeLocations = [];
    let activeStateName = "State";
    let activeLocationIndex = 0;

    function closeCampModal() {
      if (typeof modal.close === "function") {
        modal.close();
      } else {
        modal.hidden = true;
        modal.removeAttribute("open");
      }
      document.body.classList.remove("tom-modal-open");
    }

    function setActiveAreaButton(index) {
      areas.querySelectorAll(".tom-camp-modal__area").forEach((areaButton, areaIndex) => {
        areaButton.setAttribute("aria-pressed", areaIndex === index ? "true" : "false");
      });
    }

    function updatePager() {
      const hasMultipleLocations = activeLocations.length > 1;

      if (switcher) switcher.hidden = activeLocations.length === 0;
      if (previousButton) previousButton.hidden = !hasMultipleLocations;
      if (nextButton) nextButton.hidden = !hasMultipleLocations;
      if (count) {
        count.textContent = hasMultipleLocations ? `${activeLocationIndex + 1} of ${activeLocations.length}` : "";
        count.hidden = !hasMultipleLocations;
      }
    }

    function activateLocation(index) {
      const location = activeLocations[index];
      if (!location) return;

      activeLocationIndex = index;
      setActiveAreaButton(index);
      updatePager();

      notes.innerHTML = location.notesHtml || location.notes || "Camp details will be updated soon.";

      if (location.registrationLink) {
        link.href = location.registrationLink;
        link.hidden = false;
      } else {
        link.removeAttribute("href");
        link.hidden = true;
      }

      if (location.flyerImage) {
        image.src = location.flyerImage;
        image.alt = `${activeStateName} ${location.area || "camp"} flyer`;
        image.hidden = false;
        placeholder.hidden = true;
      } else {
        image.removeAttribute("src");
        image.alt = "";
        image.hidden = true;
        placeholder.hidden = false;
      }
    }

    function openCampModal(detail) {
      activeStateName = detail.state || "State";
      activeLocations = Array.isArray(detail.locations) ? detail.locations : [];
      activeLocationIndex = 0;

      state.textContent = `${activeStateName} Camp`;
      areas.innerHTML = "";
      updatePager();

      if (!activeLocations.length) {
        notes.textContent = "No Camp details have been published for this state yet.";
        link.removeAttribute("href");
        link.hidden = true;
        image.removeAttribute("src");
        image.alt = "";
        image.hidden = true;
        placeholder.hidden = false;

        document.body.classList.add("tom-modal-open");
        if (typeof modal.showModal === "function") {
          modal.showModal();
        } else {
          modal.hidden = false;
          modal.setAttribute("open", "");
        }
        return;
      }

      activeLocations.forEach((location, index) => {
        const button = document.createElement("button");
        button.type = "button";
        button.className = "tom-camp-modal__area";
        button.textContent = location.area || `Location ${index + 1}`;
        button.setAttribute("aria-pressed", index === 0 ? "true" : "false");
        button.addEventListener("click", () => {
          activateLocation(index);
        });
        areas.appendChild(button);
      });

      activateLocation(0);

      document.body.classList.add("tom-modal-open");
      if (typeof modal.showModal === "function") {
        modal.showModal();
      } else {
        modal.hidden = false;
        modal.setAttribute("open", "");
      }
    }

    campDetails.querySelectorAll("[data-camp-state]").forEach((button) => {
      button.addEventListener("click", () => {
        try {
          openCampModal(JSON.parse(button.dataset.campState || "{}"));
        } catch (_error) {
          openCampModal({ state: button.textContent.trim() });
        }
      });
    });

    if (closeButton) closeButton.addEventListener("click", closeCampModal);
    if (previousButton) {
      previousButton.addEventListener("click", () => {
        if (!activeLocations.length) return;
        const previousIndex = (activeLocationIndex - 1 + activeLocations.length) % activeLocations.length;
        activateLocation(previousIndex);
      });
    }
    if (nextButton) {
      nextButton.addEventListener("click", () => {
        if (!activeLocations.length) return;
        const nextIndex = (activeLocationIndex + 1) % activeLocations.length;
        activateLocation(nextIndex);
      });
    }

    modal.addEventListener("click", (event) => {
      if (event.target === modal) closeCampModal();
    });
  });

  document.querySelectorAll("[data-camp-admin-editor]").forEach((editor) => {
    if (editor.dataset.campAdminBound) return;
    editor.dataset.campAdminBound = "true";

    const tabs = editor.querySelectorAll("[data-camp-admin-tab]");
    const panels = editor.querySelectorAll("[data-camp-admin-panel]");

    function activate(stateKey) {
      tabs.forEach((tab) => {
        tab.setAttribute("aria-selected", tab.dataset.campAdminTab === stateKey ? "true" : "false");
      });

      panels.forEach((panel) => {
        panel.hidden = panel.dataset.campAdminPanel !== stateKey;
      });
    }

    tabs.forEach((tab) => {
      tab.addEventListener("click", () => activate(tab.dataset.campAdminTab));
    });

    editor.querySelectorAll("[data-camp-add-area]").forEach((button) => {
      button.addEventListener("click", () => {
        const stateKey = button.dataset.campAddArea;
        const list = editor.querySelector(`[data-camp-area-list="${stateKey}"]`);
        const template = editor.querySelector(`[data-camp-area-template="${stateKey}"]`);
        if (!list || !template) return;

        const uniqueId = `${Date.now()}${Math.floor(Math.random() * 100000)}`;
        const wrapper = document.createElement("div");
        wrapper.innerHTML = template.innerHTML.replace(/NEW_RECORD/g, uniqueId);
        list.append(...wrapper.childNodes);
      });
    });

    editor.addEventListener("click", (event) => {
      const removeButton = event.target.closest("[data-camp-remove-area]");
      if (!removeButton) return;

      removeButton.closest(".camp-admin-location")?.remove();
    });

    activate(tabs[0]?.dataset.campAdminTab || "");
  });

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
  document.querySelectorAll(".tom-team-popup.is-open").forEach((popup) => {
    popup.classList.remove("is-open");
  });
  document.body.classList.remove("tom-modal-open");

  document.querySelectorAll("[data-global-modal]").forEach((globalModal) => {
    if (typeof globalModal.close === "function") {
      if (globalModal.open) globalModal.close();
    } else {
      globalModal.removeAttribute("open");
      globalModal.remove();
    }
  });

  document.querySelectorAll("[data-camp-modal]").forEach((campModal) => {
    if (typeof campModal.close === "function") {
      if (campModal.open) campModal.close();
    } else {
      campModal.removeAttribute("open");
      campModal.hidden = true;
    }
  });
});

document.addEventListener("keydown", (event) => {
  if (event.key !== "Escape") return;

  const openTeamPopup = document.querySelector(".tom-team-popup.is-open");
  if (openTeamPopup) {
    openTeamPopup.classList.remove("is-open");
    document.body.classList.remove("tom-modal-open");
    history.replaceState(null, "", "#leadership");
  }

  const openCampModal = document.querySelector("[data-camp-modal][open]");
  if (openCampModal && typeof openCampModal.close === "function") {
    openCampModal.close();
    document.body.classList.remove("tom-modal-open");
  }
});

document.addEventListener("turbo:load", initPublicSite);
document.addEventListener("DOMContentLoaded", initPublicSite);
