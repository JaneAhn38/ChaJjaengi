<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Date"%>
<html>
<head>
	<link rel="stylesheet" href="resources/css/bootstrap.min.css" />
	<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
	<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />

	<title>차쟁이 | AnyoneHere?</title>
	<style>
		:root {
			--figma-bg: #1C1C1C;
			--figma-card-bg: #FFFFFF;
			--figma-point-red: #FF3B30;
			--figma-text-gray: #8A8A8E;
			--figma-border: rgba(0,0,0,0.05);
		}

		body {
			background-color: #F2F2F7; /* 스크린샷의 약간 회색 배경 */
			color: #1C1C1E;
			font-family: 'Inter', sans-serif;
			margin: 0;
			padding: 0;
		}

		/* 1. Figma 네비게이션바 (동적 로직은 기존 menu.jsp 따름, 스타일만 재현) */
		.custom-nav {
			background-color: var(--figma-bg);
			padding: 0.5rem 2rem;
			color: white;
			position: sticky;
			top: 0;
			z-index: 1000;
		}

		.nav-left {
			display: flex;
			align-items: center;
			gap: 15px;
		}
		.home-icon-box {
			background-color: #3A3A3C;
			padding: 10px;
			border-radius: 12px;
			color: var(--figma-point-red);
			font-size: 1.2rem;
			text-decoration: none;
		}
		.nav-home-text { font-weight: 700; font-size: 1.1rem; color: white; text-decoration: none;}

		.nav-center {
			text-align: center;
		}
		.nav-center h1 { font-size: 1.5rem; font-weight: 800; margin: 0; color: white; }
		.nav-center h2 { font-size: 0.8rem; font-weight: 700; margin: 0; color: white; }

		.nav-right {
			display: flex;
			align-items: center;
			gap: 20px;
			font-size: 0.9rem;
			color: rgba(255,255,255,0.8);
		}
		.nav-link-item { text-decoration: none; color: inherit; transition: 0.2s; cursor: pointer;}
		.nav-link-item:hover { color: white; }
		.nav-signup-btn {
			background-color: var(--figma-point-red);
			color: white;
			border: none;
			padding: 8px 18px;
			border-radius: 12px;
			font-weight: 700;
			text-decoration: none;
		}
		.nav-signup-btn:hover { background-color: #D62F26; color: white;}

		/* 2. 상단 통계 위젯 영역 (Figma 재현) */
		.stats-section {
			padding: 30px 0;
		}
		.stat-card {
			background-color: var(--figma-card-bg);
			border-radius: 20px;
			padding: 25px;
			text-align: center;
			border: 1px solid var(--figma-border);
			box-shadow: 0 4px 15px rgba(0,0,0,0.03);
			height: 100%;
		}
		.stat-icon {
			font-size: 1.5rem;
			color: var(--figma-point-red);
			margin-bottom: 15px;
		}
		.stat-label {
			color: var(--figma-text-gray);
			font-size: 0.8rem;
			font-weight: 600;
			margin-bottom: 5px;
		}
		.stat-value {
			font-size: 1.4rem;
			font-weight: 800;
			color: #1C1C1E;
		}
		.stat-unit { font-size: 1.1rem; font-weight: 700;}

		/* 3. 지도 및 인기 스팟 메인 컨텐츠 영역 */
		.main-content {
			padding-bottom: 50px;
		}
		.figma-section-title {
			font-size: 1.3rem;
			font-weight: 800;
			margin-bottom: 10px;
			display: flex;
			align-items: center;
			gap: 10px;
		}
		.figma-section-subtitle {
			color: var(--figma-text-gray);
			font-size: 0.9rem;
			margin-bottom: 25px;
		}

		/* 지도 카드 */
		.map-card {
			background-color: var(--figma-card-bg);
			border-radius: 25px;
			padding: 25px;
			border: 1px solid var(--figma-border);
			box-shadow: 0 5px 20px rgba(0,0,0,0.03);
		}
		#map {
			height: 500px;
			border-radius: 20px;
			border: 1px solid rgba(0,0,0,0.1);
		}

		/* 인기 스팟 리스트 */
		.spot-list-card {
			background-color: var(--figma-card-bg);
			border-radius: 25px;
			padding: 25px;
			border: 1px solid var(--figma-border);
			box-shadow: 0 5px 20px rgba(0,0,0,0.03);
		}
		.spot-item {
			display: flex;
			justify-content: space-between;
			align-items: center;
			padding: 15px;
			border-radius: 15px;
			background-color: rgba(0,0,0,0.02);
			border: 1px solid var(--figma-border);
			margin-bottom: 15px;
		}
		.spot-item-left {
			display: flex;
			align-items: center;
			gap: 15px;
		}
		.spot-pin {
			color: var(--figma-point-red);
			font-size: 1.1rem;
		}
		.spot-name { font-weight: 700; font-size: 1rem; color: #1C1C1E;}
		.spot-coord { font-size: 0.75rem; color: var(--figma-text-gray);}

		.spot-item-right {
			background-color: #F2F2F7;
			padding: 8px 12px;
			border-radius: 10px;
			color: var(--figma-point-red);
			font-weight: 700;
			font-size: 0.9rem;
			display: flex;
			align-items: center;
			gap: 5px;
		}

		/* 지도 레이블 스타일 고도화 */
		.district-label { font-size: 11px; font-weight: bold; color: #1C1C1E; text-shadow: none; background: none; border: none; }
		.dong-label { font-size: 10px; color: #555; background: none; border: none; }

		/* 팝업 스타일 커스텀 */
		.leaflet-popup-content-wrapper { border-radius: 12px; }
		.custom-popup-content { padding: 5px; text-align: center;}
	</style>
</head>
<body>

<nav class="custom-nav d-flex justify-content-between align-items-center">
	<div class="nav-left">
		<a href="#" class="home-icon-box"><i class="fa-solid fa-home"></i></a>
		<a href="#" class="nav-home-text">Home</a>
	</div>
	<div class="nav-center">
		<h1>차쟁이</h1>
		<h2>AnyoneHere?</h2>
	</div>
	<div class="nav-right">
		<a class="nav-link-item"><i class="fa-solid fa-location-dot"></i> 스팟 보기</a>
		<a class="nav-link-item"><i class="fa-solid fa-comments"></i> 커뮤니티</a>
		<a class="nav-link-item"><i class="fa-solid fa-sign-in-alt"></i> 로그인</a>
		<a href="#" class="nav-signup-btn"><i class="fa-solid fa-user-plus"></i> 회원가입</a>
	</div>
</nav>

<div class="container-fluid stats-section px-5">
	<div class="row">
		<div class="col-md-3">
			<div class="stat-card">
				<i class="fa-solid fa-thumbtack stat-icon"></i>
				<div class="stat-label">등록된 스팟</div>
				<div class="stat-value">6<span class="stat-unit">곳</span></div>
			</div>
		</div>
		<div class="col-md-3">
			<div class="stat-card">
				<i class="fa-solid fa-users stat-icon"></i>
				<div class="stat-label">지금 활동중</div>
				<div class="stat-value">68<span class="stat-unit">명</span></div>
			</div>
		</div>
		<div class="col-md-3">
			<div class="stat-card">
				<i class="fa-solid fa-fire stat-icon"></i>
				<div class="stat-label">가장 핫한 곳</div>
				<div class="stat-value" style="font-size:1.1rem; padding-top:5px;">여의도 한강공원</div>
			</div>
		</div>
		<div class="col-md-3">
			<div class="stat-card">
				<i class="fa-solid fa-chart-bar stat-icon"></i>
				<div class="stat-label">평균 인원</div>
				<div class="stat-value">11<span class="stat-unit">명</span></div>
			</div>
		</div>
	</div>
</div>

<div class="container-fluid main-content px-5">
	<div class="row">
		<div class="col-lg-8">
			<div class="map-card">
				<div class="figma-section-title">지도에서 찾기 <i class="fa-solid fa-search" style="color:var(--figma-point-red); font-size:1rem;"></i></div>
				<div class="figma-section-subtitle">체크 마크를 눌러보세요!</div>
				<div id="map"></div>
			</div>
		</div>
		<div class="col-lg-4">
			<div class="spot-list-card">
				<div class="figma-section-title">인기 스팟 <i class="fa-solid fa-star" style="color:#FFCC00;"></i></div>
				<div class="figma-section-subtitle">많은 차쟁이들이 모여있는 곳이에요.</div>

				<div class="spot-item">
					<div class="spot-item-left">
						<i class="fa-solid fa-location-pin spot-pin"></i>
						<div>
							<div class="spot-name">여의도 한강...</div>
							<div class="spot-coord">37.5285, 126.9331</div>
						</div>
					</div>
					<div class="spot-item-right"><i class="fa-solid fa-users"></i> 23</div>
				</div>

				<div class="spot-item">
					<div class="spot-item-left">
						<i class="fa-solid fa-location-pin spot-pin"></i>
						<div>
							<div class="spot-name">잠실 롯데월드</div>
							<div class="spot-coord">37.5111, 127.0980</div>
						</div>
					</div>
					<div class="spot-item-right"><i class="fa-solid fa-users"></i> 15</div>
				</div>

				<div class="spot-item" style="margin-bottom:0;">
					<div class="spot-item-left">
						<i class="fa-solid fa-location-pin spot-pin"></i>
						<div>
							<div class="spot-name">강남 카페거리</div>
							<div class="spot-coord">37.4979, 127.0276</div>
						</div>
					</div>
					<div class="spot-item-right"><i class="fa-solid fa-users"></i> 12</div>
				</div>
			</div>
		</div>
	</div>

	<div class="mt-5 pb-5">
		<%@ include file="common/footer.jsp"%>
	</div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
	// 기존 지도 로직 기반, 스타일만 Figma 재현
	var DONG_ZOOM = 13;
	var GYEONGGI_COLOR = '#E5E5EA'; // 스크린샷과 유사한 밝은 회색

	var map = L.map('map', {
		center: [37.6, 127.1],
		zoom: 9,
		minZoom: 8,
		maxZoom: 16,
		zoomControl: true
	});

	// Figma 스크린샷과 유사한 밝은 구역 색상
	var sectionColors = {
		'NW': '#EBF5FF', 'NE': '#F0FFF0',
		'SW': '#FFF8EB', 'SE': '#F5EBFF'
	};

	// ... [중략: 기존의 getSectionByCoord, toMainPolygon, addLabel 함수들 유지] ...
	function getSectionByCoord(lat, lng) {
		var isNorth = lat > 37.522;
		var isWest  = lng < 127.00;
		if (isNorth && isWest)  return 'NW';
		if (isNorth && !isWest) return 'NE';
		if (!isNorth && isWest) return 'SW';
		return 'SE';
	}

	function toMainPolygon(feature) {
		if (feature.geometry.type === 'MultiPolygon') {
			var largest = feature.geometry.coordinates.reduce(function(max, coords) {
				return coords[0].length > max[0].length ? coords : max;
			});
			return Object.assign({}, feature, {
				geometry: { type: 'Polygon', coordinates: largest }
			});
		}
		return feature;
	}

	function addLabel(feature, className, getText) {
		var center = L.geoJSON(feature).getBounds().getCenter();
		return L.marker(center, {
			icon: L.divIcon({
				className: className,
				html: getText(feature),
				iconSize: [80, 20], iconAnchor: [40, 10]
			})
		});
	}

	var seoulGuLayer, seoulGuLabels = [];
	var gyeonggiLayer, gyeonggiLabels = [];
	var seoulDongLayer, seoulDongLabels = [];
	var gyeonggiDongLayer, gyeonggiDongLabels = [];
	var seoulDongLoaded = false, gyeonggiDongLoaded = false;

	fetch('https://raw.githubusercontent.com/southkorea/seoul-maps/master/kostat/2013/json/seoul_municipalities_geo_simple.json')
			.then(function(r) { return r.json(); })
			.then(function(data) {
				var cleaned = data.features.map(toMainPolygon);
				seoulGuLayer = L.geoJSON({ type: 'FeatureCollection', features: cleaned }, {
					style: function(f) {
						var c = L.geoJSON(f).getBounds().getCenter();
						// Figma 스크린샷처럼 테두리는 회색, 내부는 구역별 옅은 색
						return { fillColor: sectionColors[getSectionByCoord(c.lat, c.lng)], fillOpacity: 0.8, color: '#D1D1D6', weight: 1.5 };
					}
				}).addTo(map);
				cleaned.forEach(function(f) {
					var lbl = addLabel(f, 'district-label', function(f) { return f.properties.name || ''; });
					lbl.addTo(map);
					seoulGuLabels.push(lbl);
				});
			});

	fetch('https://raw.githubusercontent.com/southkorea/southkorea-maps/master/kostat/2013/json/skorea_municipalities_geo_simple.json')
			.then(function(r) { return r.json(); })
			.then(function(data) {
				var gyeonggi = data.features
						.filter(function(f) { return (f.properties.code || '').startsWith('31'); })
						.map(toMainPolygon);
				gyeonggiLayer = L.geoJSON({ type: 'FeatureCollection', features: gyeonggi }, {
					// 경기도는 더 밝은 회색으로
					style: { fillColor: '#F2F2F7', fillOpacity: 0.7, color: '#D1D1D6', weight: 1.2 }
				}).addTo(map);
				gyeonggi.forEach(function(f) {
					var lbl = addLabel(f, 'district-label', function(f) { return f.properties.name || ''; });
					lbl.addTo(map);
					gyeonggiLabels.push(lbl);
				});
			});

	// ... [중략: loadSeoulDong, loadGyeonggiDong, showDongLevel, showGuLevel, map.on('zoomend') 등 기존 로직 유지] ...
	function loadSeoulDong() {
		if (seoulDongLoaded) return;
		seoulDongLoaded = true;
		fetch('https://raw.githubusercontent.com/southkorea/seoul-maps/master/kostat/2013/json/seoul_submunicipalities_geo_simple.json')
				.then(function(r) { return r.json(); })
				.then(function(data) {
					var cleaned = data.features.map(toMainPolygon);
					seoulDongLayer = L.geoJSON({ type: 'FeatureCollection', features: cleaned }, {
						style: function(f) {
							var c = L.geoJSON(f).getBounds().getCenter();
							return { fillColor: sectionColors[getSectionByCoord(c.lat, c.lng)], fillOpacity: 0.6, color: 'rgba(0,0,0,0.1)', weight: 0.8 };
						}
					});
					cleaned.forEach(function(f) {
						var parts = (f.properties.name || '').split(' ');
						var dongName = parts.slice(1).join(' ') || parts[0];
						var lbl = addLabel(f, 'dong-label', function() { return dongName; });
						seoulDongLabels.push(lbl);
					});
					if (map.getZoom() >= DONG_ZOOM) showDongLevel();
				});
	}

	function loadGyeonggiDong() {
		if (gyeonggiDongLoaded) return;
		gyeonggiDongLoaded = true;
		fetch('https://raw.githubusercontent.com/southkorea/southkorea-maps/master/kostat/2013/json/skorea_submunicipalities_geo_simple.json')
				.then(function(r) { return r.json(); })
				.then(function(data) {
					var gyeonggi = data.features
							.filter(function(f) { return (f.properties.code || '').startsWith('31'); })
							.map(toMainPolygon);
					gyeonggiDongLayer = L.geoJSON({ type: 'FeatureCollection', features: gyeonggi }, {
						style: { fillColor: '#F2F2F7', fillOpacity: 0.6, color: 'rgba(0,0,0,0.1)', weight: 0.8 }
					});
					gyeonggi.forEach(function(f) {
						var dongName = f.properties.name || '';
						var lbl = addLabel(f, 'dong-label', function() { return dongName; });
						gyeonggiDongLabels.push(lbl);
					});
					if (map.getZoom() >= DONG_ZOOM) showDongLevel();
				});
	}

	function showDongLevel() {
		if (seoulGuLayer)   map.removeLayer(seoulGuLayer);
		if (gyeonggiLayer)  map.removeLayer(gyeonggiLayer);
		seoulGuLabels.forEach(function(l)   { map.removeLayer(l); });
		gyeonggiLabels.forEach(function(l)  { map.removeLayer(l); });
		if (seoulDongLayer)    { map.addLayer(seoulDongLayer);    seoulDongLabels.forEach(function(l)    { l.addTo(map); }); }
		if (gyeonggiDongLayer) { map.addLayer(gyeonggiDongLayer); gyeonggiDongLabels.forEach(function(l) { l.addTo(map); }); }
	}

	function showGuLevel() {
		if (seoulDongLayer)    map.removeLayer(seoulDongLayer);
		if (gyeonggiDongLayer) map.removeLayer(gyeonggiDongLayer);
		seoulDongLabels.forEach(function(l)    { map.removeLayer(l); });
		gyeonggiDongLabels.forEach(function(l) { map.removeLayer(l); });
		if (seoulGuLayer)   map.addLayer(seoulGuLayer);
		if (gyeonggiLayer)  map.addLayer(gyeonggiLayer);
		seoulGuLabels.forEach(function(l)   { l.addTo(map); });
		gyeonggiLabels.forEach(function(l)  { l.addTo(map); });
	}

	map.on('zoomend', function() {
		if (map.getZoom() >= DONG_ZOOM) {
			loadSeoulDong();
			loadGyeonggiDong();
			showDongLevel();
		} else {
			showGuLevel();
		}
	});

	// 5. Figma 스크린샷의 레드 마커 디자인 완벽 재현
	var checkIcon = L.divIcon({
		className: '',
		html: '<div style="background:var(--figma-point-red); width:20px; height:20px; border-radius:50%; border:3px solid white; box-shadow: 0 0 12px rgba(255,59,48,0.6);"></div>',
		iconSize: [20, 20], iconAnchor: [10, 10]
	});

	fetch('<%=request.getContextPath()%>/api/spots')
			.then(function(r) { return r.json(); })
			.then(function(spots) {
				spots.forEach(function(spot) {
					var latlng = L.latLng(spot.latitude, spot.longitude);
					var marker = L.marker(latlng, { icon: checkIcon }).addTo(map);

					// 팝업 스타일도 Figma 느낌으로 세련되게
					var popup = L.popup({ className: 'custom-popup' })
							.setContent(
									'<div class="custom-popup-content">' +
									'<strong style="font-size:15px; color:#1C1C1E;">' + spot.name + '</strong><br>' +
									'<span style="color:var(--figma-point-red); font-weight:bold; font-size:13px;"><i class="fa-solid fa-users"></i> ' + spot.activeUserCount + '명 활동 중</span>' +
									'</div>'
							);
					marker.bindPopup(popup);
				});
			});
</script>
</body>
</html>