const mongoose = require('mongoose');
require('dotenv').config();
const Song = require('./models/song.model');
const Playlist = require('./models/playlist.model');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/ki_stream_db';

const playlistsData = [
    {
        name: 'Classics',
        mood: 'Classic',
        imagePath: 'playlist-images/Classics.jpg',
        songs: [
            { artist: 'a-ha', name: 'Take On Me', file: 'a-ha - Take On Me.mp3', image: 'a-ha - Take On Me.jpg' },
            { artist: 'Ice Cube', name: 'It Was A Good Day', file: 'Ice Cube - It Was A Good Day.mp3', image: 'Ice Cube - It Was A Good Day.jpg' },
            { artist: 'Linkin Park', name: 'In The End', file: 'Linkin Park - In The End.mp3', image: 'Linkin Park - In The End.jpg' },
            { artist: 'Linkin Park', name: 'Numb', file: 'Linkin Park - Numb .mp3', image: 'Linkin Park - Numb.jpg' },
            { artist: 'Miki Matsubara', name: 'Stay With Me', file: 'Miki Matsubara - Stay With Me.mp3', image: 'Miki Matsubara - Stay With Me.jpg' },
            { artist: 'Panjabi MC', name: 'Mundian To Bach Ke (Beware Of The Boys)', file: 'Panjabi MC - Mundian To Bach Ke (Beware Of The Boys).mp3', image: 'Panjabi MC - Mundian To Bach Ke (Beware Of The Boys).jpg' },
            { artist: 'Punjabi MC', name: 'Jogi', file: 'Punjabi MC - Jogi.mp3', image: 'Punjabi MC - Jogi.jpg' },
            { artist: 'Toto', name: 'Africa', file: 'Toto - Africa.mp3', image: 'Toto - Africa.jpg' }
        ]
    },
    {
        name: 'Dark',
        mood: 'Dark',
        imagePath: 'playlist-images/Dark.jpg',
        songs: [
            { artist: 'S.T.A.L.K.E.R.', name: 'Best Guitar Campfire Songs', file: 'S.T.A.L.K.E.R. - Best Guitar Campfire Songs.mp3', image: 'S.T.A.L.K.E.R. - Best Guitar Campfire Songs.jpg' },
            { artist: 'Resident Evil 4', name: 'Serenity Rainy Mood', file: 'Resident Evil 4 - Serenity Rainy Mood.mp3', image: 'Resident Evil 4 - Serenity Rainy Mood.jpg' },
            { artist: 'Resident Evil 7', name: 'Save Room Song (slowed)', file: 'Resident Evil 7 - Save Room Song (slowed).mp3', image: 'Resident Evil 7 - Save Room Song (slowed).jpg' },
            { artist: 'Resident Evil 8 Village', name: 'Save Room Theme', file: 'Resident Evil 8 Village - Save Room Theme.mp3', image: 'Resident Evil 8 Village - Save Room Theme.jpg' }
        ]
    },
    {
        name: 'Slowed Down',
        mood: 'Chill',
        imagePath: 'playlist-images/Slowed Down.jpg',
        songs: [
            { artist: 'the police', name: 'every breath you take (slowed down)', file: 'the police - every breath you take (slowed down).mp3', image: 'the police - every breath you take (slowed down).jpg' },
            { artist: 'the weeknd', name: 'blinding lights (slowed  reverb)', file: 'the weeknd - blinding lights (slowed  reverb).mp3', image: 'the weeknd - blinding lights (slowed  reverb).jpg' }
        ]
    },
    {
        name: 'Phonk',
        mood: 'Aggressive',
        imagePath: 'playlist-images/Phonk.jpg',
        songs: [
            { artist: '$WERVE', name: 'CITY LIGHT$', file: '$WERVE - CITY LIGHT$.mp3', image: '$WERVE - CITY LIGHT$.jpg' },
            { artist: '5admin', name: 'Silence', file: '5admin - Silence.mp3', image: '5admin - Silence.jpg' },
            { artist: 'DVRST', name: 'Close Eyes', file: 'DVRST - Close Eyes.mp3', image: 'DVRST - Close Eyes.jpg' },
            { artist: 'DVRST', name: 'My Toy', file: 'DVRST - My Toy.mp3', image: 'DVRST - My Toy.jpg' },
            { artist: 'DVRST', name: 'REASON TO LIVE', file: 'DVRST - REASON TO LIVE.mp3', image: 'DVRST - REASON TO LIVE.jpg' },
            { artist: 'Hensonn', name: 'Sahara', file: 'Hensonn-Sahara.mp3', image: 'Hensonn-Sahara.jpg' },
            { artist: 'INTERWORLD', name: 'RAPTURE (PHONK)', file: 'INTERWORLD - RAPTURE (PHONK).mp3', image: 'INTERWORLD - RAPTURE (PHONK).jpg' },
            { artist: 'PLAYAMANE x Nateki', name: 'MIDNIGHT', file: 'PLAYAMANE x Nateki - MIDNIGHT.mp3', image: 'PLAYAMANE x Nateki - MIDNIGHT.jpg' },
            { artist: 'PlayaPhonk', name: 'PHONKY TOWN', file: 'PlayaPhonk - PHONKY TOWN .mp3', image: 'PlayaPhonk - PHONKY TOWN.jpg' }
        ]
    }
];

async function seedDatabase() {
    try {
        await mongoose.connect(MONGODB_URI);
        console.log('Connected to MongoDB for seeding...');

        // Clear existing data
        await Song.deleteMany({});
        await Playlist.deleteMany({});
        console.log('Cleared existing songs and playlists.');

        for (const playlistItem of playlistsData) {
            const songIds = [];

            for (const songData of playlistItem.songs) {
                // Check if song already exists (it might be in multiple playlists)
                let song = await Song.findOne({ songName: songData.name, artistName: songData.artist });

                if (!song) {
                    song = new Song({
                        songName: songData.name,
                        artistName: songData.artist,
                        audioFile: `songs/${songData.file}`,
                        songImage: `song-images/${songData.image}`,
                        albumName: playlistItem.name,
                        isManual: false,
                        isFavorite: false,
                        color: '#000000',
                        duration: '0:00'
                    });
                    await song.save();
                }
                songIds.push(song._id);
            }

            const playlist = new Playlist({
                name: playlistItem.name,
                mood: playlistItem.mood,
                songIds: songIds,
                imagePath: playlistItem.imagePath,
                creatorName: 'Admin'
            });

            await playlist.save();
            console.log(`Created playlist: ${playlistItem.name} with ${songIds.length} songs.`);
        }

        console.log('Database seeding completed successfully!');
        process.exit(0);
    } catch (error) {
        console.error('Error seeding database:', error);
        process.exit(1);
    }
}

seedDatabase();
