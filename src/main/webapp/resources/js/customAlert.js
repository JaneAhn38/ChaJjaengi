// 브라우저 기본 alert() 대신 쓰는 테마 스타일 팝업.
// 사용법: showAlert("메시지") 또는 showAlert("메시지", function() { ...확인 누른 뒤 실행할 동작... });
function showAlert(message, onClose) {
    var overlay = document.createElement('div');
    overlay.className = 'custom-alert-overlay';

    var box = document.createElement('div');
    box.className = 'custom-alert-box';

    var msg = document.createElement('div');
    msg.className = 'custom-alert-message';
    msg.textContent = message;

    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'custom-alert-ok-btn';
    btn.textContent = '확인';

    function close() {
        if (overlay.parentNode) overlay.parentNode.removeChild(overlay);
        document.removeEventListener('keydown', onKeydown);
        if (typeof onClose === 'function') onClose();
    }
    function onKeydown(e) {
        if (e.key === 'Enter' || e.key === 'Escape') close();
    }

    btn.addEventListener('click', close);
    overlay.addEventListener('click', function(e) {
        if (e.target === overlay) close();
    });
    document.addEventListener('keydown', onKeydown);

    box.appendChild(msg);
    box.appendChild(btn);
    overlay.appendChild(box);
    document.body.appendChild(overlay);
    btn.focus();
}
