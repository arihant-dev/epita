// ==================== Theme Toggle ====================
const themeToggle = document.getElementById('theme-toggle');
const html = document.documentElement;

// Check for saved theme preference or default to 'light'
const currentTheme = localStorage.getItem('theme') || 'light';
html.setAttribute('data-theme', currentTheme);
updateThemeIcon(currentTheme);

themeToggle.addEventListener('click', () => {
    const theme = html.getAttribute('data-theme');
    const newTheme = theme === 'light' ? 'dark' : 'light';
    
    html.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    updateThemeIcon(newTheme);
});

function updateThemeIcon(theme) {
    const icon = themeToggle.querySelector('i');
    if (theme === 'dark') {
        icon.classList.remove('fa-moon');
        icon.classList.add('fa-sun');
    } else {
        icon.classList.remove('fa-sun');
        icon.classList.add('fa-moon');
    }
}

// ==================== Mobile Menu Toggle ====================
const mobileMenuToggle = document.getElementById('mobile-menu-toggle');
const navMenu = document.getElementById('nav-menu');

mobileMenuToggle.addEventListener('click', () => {
    navMenu.classList.toggle('active');
    const icon = mobileMenuToggle.querySelector('i');
    
    if (navMenu.classList.contains('active')) {
        icon.classList.remove('fa-bars');
        icon.classList.add('fa-times');
    } else {
        icon.classList.remove('fa-times');
        icon.classList.add('fa-bars');
    }
});

// Close mobile menu when clicking on a link
const navLinks = document.querySelectorAll('.nav-link');
navLinks.forEach(link => {
    link.addEventListener('click', () => {
        navMenu.classList.remove('active');
        const icon = mobileMenuToggle.querySelector('i');
        icon.classList.remove('fa-times');
        icon.classList.add('fa-bars');
    });
});

// ==================== Smooth Scrolling ====================
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        
        if (target) {
            const navbarHeight = document.querySelector('.navbar').offsetHeight;
            const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - navbarHeight;
            
            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });
        }
    });
});

// ==================== Navbar Scroll Effect ====================
const navbar = document.getElementById('navbar');
let lastScroll = 0;

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;
    
    if (currentScroll > 100) {
        navbar.style.boxShadow = '0 4px 20px var(--shadow-lg)';
    } else {
        navbar.style.boxShadow = '0 2px 10px var(--shadow)';
    }
    
    lastScroll = currentScroll;
});

// ==================== Active Navigation Link ====================
const sections = document.querySelectorAll('section[id]');

function highlightNavigation() {
    const scrollY = window.pageYOffset;
    
    sections.forEach(section => {
        const sectionHeight = section.offsetHeight;
        const sectionTop = section.offsetTop - 100;
        const sectionId = section.getAttribute('id');
        const navLink = document.querySelector(`.nav-link[href="#${sectionId}"]`);
        
        if (scrollY > sectionTop && scrollY <= sectionTop + sectionHeight) {
            navLinks.forEach(link => link.classList.remove('active'));
            if (navLink) {
                navLink.classList.add('active');
            }
        }
    });
}

window.addEventListener('scroll', highlightNavigation);

// ==================== Intersection Observer for Animations ====================
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe all sections
const animatedElements = document.querySelectorAll('.section');
animatedElements.forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
});

// ==================== Contact Form Handling ====================
const contactForm = document.getElementById('contact-form');

contactForm.addEventListener('submit', (e) => {
    e.preventDefault();
    
    // Get form data
    const formData = new FormData(contactForm);
    const data = {
        name: formData.get('name'),
        email: formData.get('email'),
        subject: formData.get('subject'),
        message: formData.get('message')
    };
    
    // Here you would typically send the data to a server
    // For now, we'll just show a success message
    console.log('Form submitted:', data);
    
    // Show success message
    const submitButton = contactForm.querySelector('button[type="submit"]');
    const originalText = submitButton.textContent;
    submitButton.textContent = 'Message Sent! ✓';
    submitButton.style.background = '#10b981';
    
    // Reset form
    contactForm.reset();
    
    // Reset button after 3 seconds
    setTimeout(() => {
        submitButton.textContent = originalText;
        submitButton.style.background = '';
    }, 3000);
});

// ==================== Typing Effect for Hero Title ====================
function typeWriter(element, text, speed = 100) {
    let i = 0;
    element.textContent = '';
    
    function type() {
        if (i < text.length) {
            element.textContent += text.charAt(i);
            i++;
            setTimeout(type, speed);
        }
    }
    
    type();
}

// Add typing effect on page load
window.addEventListener('load', () => {
    const heroTitle = document.querySelector('.hero-title');
    if (heroTitle) {
        const originalText = heroTitle.textContent;
        // Uncomment the line below to enable typing effect
        // typeWriter(heroTitle, originalText, 100);
    }
});

// ==================== Scroll Progress Indicator ====================
function updateScrollProgress() {
    const winScroll = document.body.scrollTop || document.documentElement.scrollTop;
    const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
    const scrolled = (winScroll / height) * 100;
    
    // You can add a progress bar element if needed
    // document.getElementById('progressBar').style.width = scrolled + '%';
}

window.addEventListener('scroll', updateScrollProgress);

// ==================== Particle Effect (Optional Enhancement) ====================
function createParticle(x, y) {
    const particle = document.createElement('div');
    particle.style.position = 'fixed';
    particle.style.left = x + 'px';
    particle.style.top = y + 'px';
    particle.style.width = '5px';
    particle.style.height = '5px';
    particle.style.borderRadius = '50%';
    particle.style.background = 'var(--primary-color)';
    particle.style.pointerEvents = 'none';
    particle.style.opacity = '1';
    particle.style.zIndex = '9999';
    
    document.body.appendChild(particle);
    
    // Animate particle
    const animation = particle.animate([
        { transform: 'translateY(0) scale(1)', opacity: 1 },
        { transform: 'translateY(-50px) scale(0)', opacity: 0 }
    ], {
        duration: 1000,
        easing: 'cubic-bezier(0, 0.5, 0.5, 1)'
    });
    
    animation.onfinish = () => {
        particle.remove();
    };
}

// Add particle effect on button clicks (optional)
const buttons = document.querySelectorAll('.btn');
buttons.forEach(button => {
    button.addEventListener('click', (e) => {
        const rect = button.getBoundingClientRect();
        const x = rect.left + rect.width / 2;
        const y = rect.top + rect.height / 2;
        
        // Create multiple particles
        for (let i = 0; i < 5; i++) {
            setTimeout(() => {
                createParticle(
                    x + (Math.random() - 0.5) * 20,
                    y + (Math.random() - 0.5) * 20
                );
            }, i * 50);
        }
    });
});

// ==================== Lazy Loading Images ====================
if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.remove('lazy');
                imageObserver.unobserve(img);
            }
        });
    });
    
    const lazyImages = document.querySelectorAll('img.lazy');
    lazyImages.forEach(img => imageObserver.observe(img));
}

// ==================== Skills Animation on Scroll ====================
const skillTags = document.querySelectorAll('.skill-tag');
const skillObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.animation = 'fadeInUp 0.5s ease forwards';
        }
    });
}, { threshold: 0.5 });

skillTags.forEach((tag, index) => {
    tag.style.animationDelay = `${index * 0.05}s`;
    skillObserver.observe(tag);
});

// ==================== Project Cards Hover Effect ====================
const projectCards = document.querySelectorAll('.project-card');

projectCards.forEach(card => {
    card.addEventListener('mouseenter', function() {
        this.style.transform = 'translateY(-8px) scale(1.02)';
    });
    
    card.addEventListener('mouseleave', function() {
        this.style.transform = 'translateY(0) scale(1)';
    });
});

// ==================== Console Message ====================
console.log('%c🚀 Welcome to Arihant\'s Portfolio!', 'color: #2563eb; font-size: 20px; font-weight: bold;');
console.log('%cBuilt with ❤️ and modern web technologies', 'color: #6b7280; font-size: 14px;');
console.log('%cGitHub: https://github.com/arihant-dev', 'color: #7c3aed; font-size: 12px;');

// ==================== Performance Monitoring ====================
window.addEventListener('load', () => {
    // Log page load time
    const loadTime = window.performance.timing.domContentLoadedEventEnd - window.performance.timing.navigationStart;
    console.log(`⚡ Page loaded in ${loadTime}ms`);
});

// ==================== Service Worker Registration (PWA Support) ====================
if ('serviceWorker' in navigator) {
    // Uncomment to enable service worker
    // navigator.serviceWorker.register('/sw.js')
    //     .then(reg => console.log('Service Worker registered'))
    //     .catch(err => console.log('Service Worker registration failed'));
}

// ==================== Add Resume Download Functionality ====================
// You can add this function when you have a resume PDF
function downloadResume() {
    // Example: window.open('/path/to/resume.pdf', '_blank');
    console.log('Resume download functionality - Add your resume PDF');
}

// ==================== Copy Email to Clipboard ====================
function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(() => {
        console.log('Copied to clipboard:', text);
        // You can show a toast notification here
    }).catch(err => {
        console.error('Failed to copy:', err);
    });
}

// Add click handler to email elements
document.querySelectorAll('.contact-method').forEach(method => {
    const emailText = method.querySelector('p');
    if (emailText && emailText.textContent.includes('@')) {
        method.style.cursor = 'pointer';
        method.addEventListener('click', () => {
            copyToClipboard(emailText.textContent);
        });
    }
});

// ==================== Initialize on DOM Load ====================
document.addEventListener('DOMContentLoaded', () => {
    // Add fade-in animation to hero section
    const hero = document.querySelector('.hero');
    if (hero) {
        hero.style.opacity = '0';
        setTimeout(() => {
            hero.style.transition = 'opacity 1s ease';
            hero.style.opacity = '1';
        }, 100);
    }
    
    // Initialize scroll highlight
    highlightNavigation();
});
