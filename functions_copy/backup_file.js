const functions = require('firebase-functions');

exports.myAlgoliaGeoTransform = functions
    .https.onCall((callData, context) => {
        functions.logger.log('--- myAlgoliaGeoTransform START ---');

        const data = callData?.data;
        if (!data) {
            functions.logger.error('🚨 CRITICAL: callData.data is missing! Received keys:', Object.keys(callData || {}));
            return {};
        }

        functions.logger.log('✅ Firestore Data keys RECEIVED:', Object.keys(data));
        functions.logger.log('🔍 FULL DATA STRUCTURE:', JSON.stringify(data, null, 2));

        const algoliaRecord = {};

        const safeFields = [
            'description', 'condominiumName', 'condominiumName_searchKey',
            'rent', 'roomType', 'gender', 'location', 'imageUrls',
            'userId', 'username', 'userProfileImageUrl', 'likeCount',
            'likedBy', 'manualTags', 'status', 'reportedBy','durationMonths'
        ];

        safeFields.forEach(field => {
            if (data[field] !== undefined) {
                algoliaRecord[field] = data[field];
            }
        });

        try {
            let lat, lng;

            // --- Step 1: JSON化（ネイティブ型対策）---
            const jsonData = JSON.parse(JSON.stringify(data));
            functions.logger.log('breakpoint2', { isGeoNull: jsonData.position?.geopoint == null });

            // --- Step 2: position.geopoint ---
            if (jsonData.position?.geopoint) {
                functions.logger.log('✅ jsonData.position?.geopoint: true');
                const { latitude, longitude } = jsonData.position.geopoint;
                lat = latitude;
                lng = longitude;
                functions.logger.log('✅ Extracted from JSON-safe geopoint:', { lat, lng });
            }

            // --- Step 3: position._geoloc ---
            else if (jsonData.position?._geoloc) {
                functions.logger.log('✅jsonData.position?._geoloc : true');
                const { lat: pLat, lng: pLng } = jsonData.position._geoloc;
                lat = pLat;
                lng = pLng;
                functions.logger.log('✅ Found position._geoloc:', jsonData.position._geoloc);
            }

            // --- Step 4: ルートの _geoloc ---
            else if (jsonData._geoloc) {
                functions.logger.log('✅jsonData._geoloc: true');
                lat = jsonData._geoloc.lat;
                lng = jsonData._geoloc.lng;
                functions.logger.log('✅ Found root-level _geoloc:', jsonData._geoloc);
            }

            // --- Step 5: Firestoreオブジェクト型 geopoint ---
            else if (data.position?.geopoint) {
                functions.logger.log('✅data.position?.geopoint: true');
                const gp = data.position.geopoint;
                lat = gp.latitude ?? gp._latitude;
                lng = gp.longitude ?? gp._longitude;
                functions.logger.log('✅ Found native GeoPoint object:', { lat, lng });
            }

            if (typeof lat === 'number' && typeof lng === 'number') {
                functions.logger.log("typeof lat === 'number' && typeof lng === 'number'");
                algoliaRecord._geoloc = { lat, lng };
                functions.logger.log('📍 Final _geoloc assigned:', algoliaRecord._geoloc);
            } else {
                functions.logger.warn('⚠️ No valid lat/lng found in data.');
            }
        } catch (e) {
            functions.logger.error('🔥 CRITICAL Error processing GeoPoint:', e);
        }


        // 🕒 Timestamp → UNIX 秒に変換
        try {
            const toUnixSeconds = (ts) => {
                if (ts && typeof ts._seconds === 'number') return ts._seconds;
                if (ts && typeof ts.toMillis === 'function') return Math.floor(ts.toMillis() / 1000);
                return null;
            };

            let unixTime;
            unixTime = toUnixSeconds(data.timestamp);
            if (unixTime) algoliaRecord.timestamp_unix = unixTime;
            unixTime = toUnixSeconds(data.durationStart);
            if (unixTime) algoliaRecord.durationStart_timestamp = unixTime;
            unixTime = toUnixSeconds(data.durationEnd);
            if (unixTime) algoliaRecord.durationEnd_timestamp = unixTime;
        } catch (e) {
            functions.logger.error('Error processing Timestamps:', e);
        }

        functions.logger.log('🧩 Transformed record preview (final):', JSON.stringify(algoliaRecord, null, 2));
        functions.logger.log('--- myAlgoliaGeoTransform END --- Returning clean record.');
        return algoliaRecord;
    });
