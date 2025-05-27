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
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/223/media/ZLfFOqwobyNHwuuf_1747292695.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/223/media/ZLfFOqwobyNHwuuf_1747292695.jpg",
            caption: "Amazing medical consultation tips! 🩺 #DocTime #Healthcare",
            username: "dr_ahmed_hassan",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 1245,
            commentCount: 87
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/221/media/SMcTSyXRAuHTEpUY_1747291826.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/221/media/SMcTSyXRAuHTEpUY_1747291826.jpg",
            caption: "Quick health check routine everyone should follow 💪",
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
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/208/media/zPRydfbFNSwfNWo4_1747050840.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/208/media/zPRydfbFNSwfNWo4_1747050840.jpg",
            caption: "Emergency first aid everyone should know 🚑",
            username: "emergency_doc",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 4523,
            commentCount: 298
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/174/media/jeFduKgWn4Vpv8ku_1746704514.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/174/media/AtRgJRf8MErTS6gF_1746704515.jpeg",
            caption: "Sleep better with these simple tips 😴 #SleepHealth",
            username: "sleep_specialist",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 1334,
            commentCount: 89
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/223/media/ZLfFOqwobyNHwuuf_1747292695.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/223/media/ZLfFOqwobyNHwuuf_1747292695.jpg",
            caption: "Exercise routines for busy professionals 💼🏃‍♂️",
            username: "fitness_md",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 2189,
            commentCount: 167
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/221/media/SMcTSyXRAuHTEpUY_1747291826.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/221/media/SMcTSyXRAuHTEpUY_1747291826.jpg",
            caption: "Preventive care saves lives! Book your checkup today 📅",
            username: "preventive_care_guru",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 756,
            commentCount: 34
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/208/media/zPRydfbFNSwfNWo4_1747050840.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/208/media/zPRydfbFNSwfNWo4_1747050840.jpg",
            caption: "Stress management techniques that actually work ✨",
            username: "mindful_medic",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 1567,
            commentCount: 98
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/174/media/jeFduKgWn4Vpv8ku_1746704514.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/174/media/AtRgJRf8MErTS6gF_1746704515.jpeg",
            caption: "Digital health tools changing medicine 📲 #HealthTech",
            username: "digital_health_expert",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 2876,
            commentCount: 203
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/223/media/ZLfFOqwobyNHwuuf_1747292695.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/223/media/ZLfFOqwobyNHwuuf_1747292695.jpg",
            caption: "Hydration hacks for better health 💧 Stay refreshed!",
            username: "hydration_hero",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
            likeCount: 1123,
            commentCount: 67
        ),
        .init(
            id: NSUUID().uuidString,
            videoUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/221/media/SMcTSyXRAuHTEpUY_1747291826.mp4",
            thumbnailUrl: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/221/media/SMcTSyXRAuHTEpUY_1747291826.jpg",
            caption: "Heart health tips from a cardiologist ❤️ #HeartHealth",
            username: "heart_specialist",
            userProfilePictureUrl: "https://rezaulislamtarek.github.io/portfolio/img/reza_hero.png",
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
            likeCount: 2234,
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
        )
    ]
}
