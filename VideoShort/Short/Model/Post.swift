//
//  Post.swift
//  VideoShort
//
//  Created by Rezaul Islam on 5/27/25.
//

import Foundation

struct Post: Identifiable, Codable {
    let id: String
    let videoUrl: String
    let thumbnailUrl: String
    let caption: String
    let username: String
    let userProfilePictureUrl: String
    var likeCount: Int
    var commentCount: Int
}


extension Post {
    static var posts : [Post] = [
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/174/media/jeFduKgWn4Vpv8ku_1746704514.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/174/media/AtRgJRf8MErTS6gF_1746704515.jpeg",
            caption: "Telemedicine revolution is here! 📱 Connect with doctors instantly",
            username: "tech_doctor_jane",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 3421,
            commentCount: 234
        ),
        
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/173/media/UafcT7BJdNEkL63g_1746615050.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/173/media/s5z2eIHBO0SZzjGO_1746615050.jpeg",
            caption: "মানসিক চাপ",
            username: "dr_ahmed_hassan",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 1245,
            commentCount: 87
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/76/media/ikzNrZ0q9HWZEAfX_1744517021.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/76/media/3KAoiCQzvMzh6h8Z_1744517021.jpeg",
            caption: "সুস্থ শিশু, সুখী আগামী",
            username: "healthylife_sara",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 892,
            commentCount: 45
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/208/media/zPRydfbFNSwfNWo4_1747050840.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/208/media/zPRydfbFNSwfNWo4_1747050840.jpg",
            caption: "Understanding your symptoms better 🔍 #MedicalAdvice",
            username: "medic_mike",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 2156,
            commentCount: 123
        ),
        
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/223/media/ZLfFOqwobyNHwuuf_1747292695.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/223/media/ZLfFOqwobyNHwuuf_1747292695.jpg",
            caption: "Mental health matters! Take care of yourself 🧠💙",
            username: "wellness_warrior",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 1876,
            commentCount: 156
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/221/media/SMcTSyXRAuHTEpUY_1747291826.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/221/media/SMcTSyXRAuHTEpUY_1747291826.jpg",
            caption: "Nutrition facts that will surprise you! 🥗 #HealthyEating",
            username: "nutritionist_pro",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 967,
            commentCount: 72
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/224/media/f6L2BTqOBxoafcHI_1747293579.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/224/media/f6L2BTqOBxoafcHI_1747293579.jpg",
            caption: "ওজন কমাতে দিনের শুরুতেই যা করবেন",
            username: "emergency_doc",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 4523,
            commentCount: 298
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/222/media/YXSxBL36tBTQvC7O_1747291905.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/222/media/YXSxBL36tBTQvC7O_1747291905.jpg",
            caption: "এই গরমে কী খাবেন, কী খাবেন না",
            username: "sleep_specialist",
            userProfilePictureUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/222/media/YXSxBL36tBTQvC7O_1747291905.jpg",
            likeCount: 1334,
            commentCount: 89
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/157/media/kvmI44evPaDUI6pV_1746012882.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/157/media/T0Pq4IB3v7eWTUGL_1746451416.png",
            caption: "Glow up daily with skincare💧✨",
            username: "fitness_md",
            userProfilePictureUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/157/media/T0Pq4IB3v7eWTUGL_1746451416.png",
            likeCount: 2189,
            commentCount: 167
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/149/media/KrITGhiS1Qq6GnyN_1745916255.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/149/media/KrITGhiS1Qq6GnyN_1745916255.jpg",
            caption: "দীর্ঘস্থায়ী কাশি? অবহেলা নয়",
            username: "preventive_care_guru",
            userProfilePictureUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/149/media/KrITGhiS1Qq6GnyN_1745916255.jpg",
            likeCount: 756,
            commentCount: 34
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/146/media/9nkjV07G5jqhZgb0_1745909649.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/146/media/9nkjV07G5jqhZgb0_1745909649.jpg",
            caption: "সতর্ক থাকুন, শিশুকে বাঁচান!",
            username: "mindful_medic",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 1567,
            commentCount: 98
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/75/media/GznOt1fsxSFjSH8f_1748331600.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/75/media/Hl2EoDDMf7t78DY0_1744517001.jpeg",
            caption: "অতিরিক্ত চিনি, নীরব বিষ",
            username: "digital_health_expert",
            userProfilePictureUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/75/media/Hl2EoDDMf7t78DY0_1744517001.jpeg",
            likeCount: 2876,
            commentCount: 203
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/171/media/XVYH5Ejx5jDZsTBt_1746613721.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/171/media/XVYH5Ejx5jDZsTBt_1746613721.jpg",
            caption: "কোষ্ঠকাঠিন্য",
            username: "hydration_hero",
            userProfilePictureUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/171/media/XVYH5Ejx5jDZsTBt_1746613721.jpg",
            likeCount: 1123,
            commentCount: 67
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/255/media/tjNlVAd5dt3Xpmhd_1748433905.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/255/media/jwDtCrE7KABSUA8P_1748433905.jpeg",
            caption: "বাচ্চার জ্বর হলে কি করবেন? 🥰👨‍⚕️",
            username: "heart_specialist",
            userProfilePictureUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/255/media/jwDtCrE7KABSUA8P_1748433905.jpeg",
            likeCount: 3654,
            commentCount: 287
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/208/media/zPRydfbFNSwfNWo4_1747050840.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/208/media/zPRydfbFNSwfNWo4_1747050840.jpg",
            caption: "Boost your immune system naturally 🌿 #NaturalHealth",
            username: "immune_booster",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 288234,
            commentCount: 145
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/174/media/jeFduKgWn4Vpv8ku_1746704514.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/174/media/AtRgJRf8MErTS6gF_1746704515.jpeg",
            caption: "Medical myths busted! Get the facts straight 🧐",
            username: "mythbuster_md",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 1789,
            commentCount: 112
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/174/media/jeFduKgWn4Vpv8ku_1746704514.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/174/media/AtRgJRf8MErTS6gF_1746704515.jpeg",
            caption: "Telemedicine revolution is here! 📱 Connect with doctors instantly",
            username: "tech_doctor_jane",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 3421,
            commentCount: 234
        ),
        
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/173/media/UafcT7BJdNEkL63g_1746615050.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/173/media/s5z2eIHBO0SZzjGO_1746615050.jpeg",
            caption: "মানসিক চাপ",
            username: "dr_ahmed_hassan",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 1245,
            commentCount: 87
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/76/media/ikzNrZ0q9HWZEAfX_1744517021.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/76/media/3KAoiCQzvMzh6h8Z_1744517021.jpeg",
            caption: "সুস্থ শিশু, সুখী আগামী",
            username: "healthylife_sara",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 892,
            commentCount: 45
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/208/media/zPRydfbFNSwfNWo4_1747050840.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/208/media/zPRydfbFNSwfNWo4_1747050840.jpg",
            caption: "Understanding your symptoms better 🔍 #MedicalAdvice",
            username: "medic_mike",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 2156,
            commentCount: 123
        ),
        
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/223/media/ZLfFOqwobyNHwuuf_1747292695.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/223/media/ZLfFOqwobyNHwuuf_1747292695.jpg",
            caption: "Mental health matters! Take care of yourself 🧠💙",
            username: "wellness_warrior",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 1876,
            commentCount: 156
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/221/media/SMcTSyXRAuHTEpUY_1747291826.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/221/media/SMcTSyXRAuHTEpUY_1747291826.jpg",
            caption: "Nutrition facts that will surprise you! 🥗 #HealthyEating",
            username: "nutritionist_pro",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 967,
            commentCount: 72
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/224/media/f6L2BTqOBxoafcHI_1747293579.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/224/media/f6L2BTqOBxoafcHI_1747293579.jpg",
            caption: "ওজন কমাতে দিনের শুরুতেই যা করবেন",
            username: "emergency_doc",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 4523,
            commentCount: 298
        ),
    ]
}
