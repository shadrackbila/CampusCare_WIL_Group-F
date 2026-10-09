
document.querySelectorAll('tr[data-href]').forEach(row => {
    row.addEventListener('click', e => {
        if (e.target.closest('a, button')) return;
        window.location.href = row.dataset.href;
    });
});