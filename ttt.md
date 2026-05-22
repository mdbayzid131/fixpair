GET {{baseURL}}/notification

{
    "success": true,
    "message": "Notifications retrieved successfully",
    "pagination": {
        "total": 4,
        "limit": 10,
        "page": 1,
        "totalPage": 1
    },
    "data": [
        {
            "_id": "6a0fa5eccbbfb1798b5fe094",
            "user": "6a0632bb5f5df3e95b99e707",
            "title": "Consultation Accepted",
            "message": "Your consultation request has been accepted by Bayzid cons.",
            "type": "CONSULTATION_STATUS",
            "relatedBooking": "6a0e4ae254e005fa6e63b94e",
            "read": true,
            "metadata": {
                "consultantName": "Bayzid cons",
                "status": "accepted",
                "date": "",
                "time": ""
            },
            "createdAt": "2026-05-22T00:40:12.173Z",
            "updatedAt": "2026-05-22T00:47:37.617Z",
            "id": "6a0fa5eccbbfb1798b5fe094"
        },
        {
            "_id": "6a0fa047cbbfb1798b5fde2e",
            "user": "6a0632bb5f5df3e95b99e707",
            "title": "Consultation Accepted",
            "message": "Your consultation request has been accepted by Bayzid cons.",
            "type": "CONSULTATION_STATUS",
            "relatedBooking": "6a0fa036cbbfb1798b5fde20",
            "read": true,
            "metadata": {
                "consultantName": "Bayzid cons",
                "status": "accepted",
                "date": "",
                "time": ""
            },
            "createdAt": "2026-05-22T00:16:07.082Z",
            "updatedAt": "2026-05-22T00:48:44.578Z",
            "id": "6a0fa047cbbfb1798b5fde2e"
        },
        {
            "_id": "6a0f9ff1cbbfb1798b5fddda",
            "user": "6a0632bb5f5df3e95b99e707",
            "title": "Consultation Rejected",
            "message": "Your consultation request has been rejected by Bayzid cons.",
            "type": "CONSULTATION_STATUS",
            "relatedBooking": "6a0e1a7454e005fa6e63b19a",
            "read": true,
            "metadata": {
                "consultantName": "Bayzid cons",
                "status": "rejected",
                "date": "",
                "time": ""
            },
            "createdAt": "2026-05-22T00:14:41.312Z",
            "updatedAt": "2026-05-22T00:48:44.578Z",
            "id": "6a0f9ff1cbbfb1798b5fddda"
        },
        {
            "_id": "6a0f9febcbbfb1798b5fddcb",
            "user": "6a0632bb5f5df3e95b99e707",
            "title": "Consultation Rejected",
            "message": "Your consultation request has been rejected by Bayzid cons.",
            "type": "CONSULTATION_STATUS",
            "relatedBooking": "6a0e181954e005fa6e63af3a",
            "read": true,
            "metadata": {
                "consultantName": "Bayzid cons",
                "status": "rejected",
                "date": "",
                "time": ""
            },
            "createdAt": "2026-05-22T00:14:35.479Z",
            "updatedAt": "2026-05-22T00:48:44.578Z",
            "id": "6a0f9febcbbfb1798b5fddcb"
        }
    ]
}


PATCH 