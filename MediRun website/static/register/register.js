function togglePasswordVisibility(button) {
    const targetId = button.dataset.target;
    const input = document.getElementById(targetId);
    const eyeOpen = button.querySelector('.eye-open');
    const eyeClosed = button.querySelector('.eye-closed');

    if (!input) {
        return;
    }

    const isHidden = input.type === 'password';
    input.type = isHidden ? 'text' : 'password';
    eyeOpen.style.display = isHidden ? 'none' : 'block';
    eyeClosed.style.display = isHidden ? 'block' : 'none';
}

document.querySelectorAll('.eye-icon').forEach((button) => {
    button.addEventListener('click', () => togglePasswordVisibility(button));
});
