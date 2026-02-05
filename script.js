(function() {
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'dark') {
        document.body.setAttribute('data-theme', 'dark');
    }
})();

document.addEventListener('DOMContentLoaded', () => {
    
    // --- GESTION DU THEME AMÉLIORÉE ---
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
        
        // Fermer le menu au clic sur un lien
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
        const closeBtn = document.querySelector('.modal-close');

        // Fonction pour fermer la modale
        function closeProofModal() {
            modal.classList.remove('active');
            setTimeout(() => {
                modalImg.style.display = 'none';
                modalPdf.style.display = 'none';
                modalImg.src = '';
                modalPdf.src = '';
            }, 300); // Attendre la fin de l'animation CSS
        }

        // Fermeture au clic sur le bouton X
        if (closeBtn) closeBtn.addEventListener('click', closeProofModal);

        // Fermeture au clic en dehors du contenu
        modal.addEventListener('click', (e) => {
            if (e.target === modal) closeProofModal();
        });

        // Écouteur sur tous les badges de preuve
        document.querySelectorAll('.proof-badge').forEach(badge => {
            badge.addEventListener('click', function() {
                const type = this.getAttribute('data-type'); // 'image' ou 'pdf'
                const src = this.getAttribute('data-src');   // Chemin du fichier
                const title = this.getAttribute('data-title'); // Titre à afficher

                if(modalCaption) modalCaption.textContent = title;

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
        
        // Fermeture avec la touche Echap
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
            
            // Retirer la classe active de tous les boutons et contenus
            missionTabBtns.forEach(b => b.classList.remove('active'));
            missionTabContents.forEach(content => content.classList.remove('active'));
            
            // Ajouter la classe active au bouton et contenu sélectionnés
            btn.classList.add('active');
            document.querySelector(`.mission-tab-content[data-mission="${missionId}"]`).classList.add('active');
        });
    });
});
