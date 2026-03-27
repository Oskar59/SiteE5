(function() {
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'dark') {
        document.body.setAttribute('data-theme', 'dark');
    }
})();

document.addEventListener('DOMContentLoaded', () => {
    
    // --- GESTION DU THEME ---
    const themeToggleBtn = document.getElementById('theme-toggle');
    const themeIcon = themeToggleBtn.querySelector('i');
    
    if (document.body.getAttribute('data-theme') === 'dark') {
        updateIcon('dark');
    } else {
        updateIcon('light');
    }
    
    themeToggleBtn.addEventListener('click', () => {
        let theme = document.body.getAttribute('data-theme');
        if (theme === 'dark') {
            document.body.removeAttribute('data-theme');
            localStorage.setItem('theme', 'light');
            updateIcon('light');
        } else {
            document.body.setAttribute('data-theme', 'dark');
            localStorage.setItem('theme', 'dark');
            updateIcon('dark');
        }
    });

    function updateIcon(theme) {
        if (theme === 'dark') {
            themeIcon.classList.remove('fa-moon');
            themeIcon.classList.add('fa-sun');
        } else {
            themeIcon.classList.remove('fa-sun');
            themeIcon.classList.add('fa-moon');
        }
    }

    // --- MENU BURGER ---
    const burgerMenu = document.querySelector('.burger-menu');
    const navLinks = document.querySelector('.nav-links');

    if (burgerMenu && navLinks) {
        burgerMenu.addEventListener('click', () => {
            navLinks.classList.toggle('active');
        });
        
        navLinks.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => {
                navLinks.classList.remove('active');
            });
        });
    }

    // --- SMOOTH SCROLL ---
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            if(targetId === '#') return;
            const targetSection = document.querySelector(targetId);
            if (targetSection) {
                targetSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    });

    // --- GESTION DES PREUVES / MODALE ---
    const modal = document.getElementById('proof-modal');
    
    if (modal) {
        const modalImg = document.getElementById('modal-img');
        const modalPdf = document.getElementById('modal-pdf');
        const modalCaption = document.getElementById('modal-caption');
        const modalDesc = document.getElementById('modal-desc'); // Nouveau champ description
        const closeBtn = document.querySelector('.modal-close');

        function closeProofModal() {
            modal.classList.remove('active');
            setTimeout(() => {
                modalImg.style.display = 'none';
                modalPdf.style.display = 'none';
                modalImg.src = '';
                modalPdf.src = '';
            }, 300);
        }

        if (closeBtn) closeBtn.addEventListener('click', closeProofModal);

        modal.addEventListener('click', (e) => {
            if (e.target === modal) closeProofModal();
        });

        document.querySelectorAll('.proof-badge').forEach(badge => {
            badge.addEventListener('click', function() {
                const type = this.getAttribute('data-type');
                const src = this.getAttribute('data-src');
                const title = this.getAttribute('data-title');
                const desc = this.getAttribute('data-desc'); // Récupération de la description

                if(modalCaption) modalCaption.textContent = title;
                if(modalDesc) modalDesc.textContent = desc || "Aucune description supplémentaire.";

                if (type === 'pdf') {
                    modalPdf.src = src;
                    modalPdf.style.display = 'block';
                    modalImg.style.display = 'none';
                } else {
                    modalImg.src = src;
                    modalImg.style.display = 'block';
                    modalPdf.style.display = 'none';
                }

                modal.classList.add('active');
            });
        });
        
        document.addEventListener('keydown', (e) => {
            if (e.key === "Escape" && modal.classList.contains('active')) {
                closeProofModal();
            }
        });
    }

    // --- GESTION DES ONGLETS MISSIONS ---
    const missionTabBtns = document.querySelectorAll('.mission-tab-btn');
    const missionTabContents = document.querySelectorAll('.mission-tab-content');

    missionTabBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const missionId = btn.getAttribute('data-mission');
            
            missionTabBtns.forEach(b => b.classList.remove('active'));
            missionTabContents.forEach(content => content.classList.remove('active'));
            
            btn.classList.add('active');
            document.querySelector(`.mission-tab-content[data-mission="${missionId}"]`).classList.add('active');
        });
    });
});
// --- DGFIP ACCORDION ---
function toggleDgfip(header) {
    const body = header.nextElementSibling;
    const isOpen = header.classList.contains('open');
    header.classList.toggle('open', !isOpen);
    body.classList.toggle('open', !isOpen);
}