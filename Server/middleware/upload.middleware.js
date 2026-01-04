const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure directories exist
const folders = ['public/song-images', 'public/playlist-images', 'public/songs', 'public/user-images'];
folders.forEach(folder => {
    const dir = path.join(__dirname, '..', folder);
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
});

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        let dest = 'public/';
        if (file.fieldname === 'songImage') dest += 'song-images';
        else if (file.fieldname === 'audioFile') dest += 'songs';
        else if (file.fieldname === 'imagePath') dest += 'playlist-images';
        else if (file.fieldname === 'userImageUrl') dest += 'user-images';

        cb(null, path.join(__dirname, '..', dest));
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

module.exports = upload;
