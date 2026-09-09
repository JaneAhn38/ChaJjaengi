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

// 예/아니오 확인 팝업.
// 사용법: showConfirm("메시지", function() { ...예... }, function() { ...아니오(선택)... }, { yesText, noText })
function showConfirm(message, onYes, onNo, opts) {
    opts = opts || {};
    var overlay = document.createElement('div');
    overlay.className = 'custom-alert-overlay';

    var box = document.createElement('div');
    box.className = 'custom-alert-box';

    var msg = document.createElement('div');
    msg.className = 'custom-alert-message';
    msg.textContent = message;

    var btnRow = document.createElement('div');
    btnRow.style.display = 'flex';
    btnRow.style.gap = '10px';
    btnRow.style.justifyContent = 'center';

    var noBtn = document.createElement('button');
    noBtn.type = 'button';
    noBtn.className = 'btn-figma-secondary';
    noBtn.textContent = opts.noText || '나중에';

    var yesBtn = document.createElement('button');
    yesBtn.type = 'button';
    yesBtn.className = 'custom-alert-ok-btn';
    yesBtn.textContent = opts.yesText || '확인';

    function close(callback) {
        if (overlay.parentNode) overlay.parentNode.removeChild(overlay);
        document.removeEventListener('keydown', onKeydown);
        if (typeof callback === 'function') callback();
    }
    function onKeydown(e) {
        if (e.key === 'Escape') close(onNo);
        if (e.key === 'Enter') close(onYes);
    }

    yesBtn.addEventListener('click', function() { close(onYes); });
    noBtn.addEventListener('click', function() { close(onNo); });
    overlay.addEventListener('click', function(e) {
        if (e.target === overlay) close(onNo);
    });
    document.addEventListener('keydown', onKeydown);

    btnRow.appendChild(noBtn);
    btnRow.appendChild(yesBtn);
    box.appendChild(msg);
    box.appendChild(btnRow);
    overlay.appendChild(box);
    document.body.appendChild(overlay);
    yesBtn.focus();
}
