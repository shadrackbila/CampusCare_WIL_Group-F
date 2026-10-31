const desktopQuery = window.matchMedia('(min-width: 1024px)');

function sideBar(isOpen) {

    const element = document.getElementById("sidebar");
    const openButton = document.getElementById("openBtn");
    const closeButton = document.getElementById("closeBtn");

    if (isOpen) {
        element.classList.remove("hidden");
        openButton.classList.add("hidden");
        closeButton.classList.remove("hidden");

    }
    else {
        element.classList.add("hidden");
        openButton.classList.remove("hidden");
        closeButton.classList.add("hidden");

    }

}

sideBar(desktopQuery.matches);
desktopQuery.addEventListener('change', e => sideBar(e.matches));