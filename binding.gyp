{
    "targets": [
        {
            "target_name": "addon",
            "cflags": ["-std=c++11"],
            "sources": ["native/napi_utils.h"],
            "conditions": [
                ["OS=='mac'", {
                    "sources": ["native/addon.mm"],
                    'xcode_settings': {
                        'OTHER_CFLAGS': [
                            '-fobjc-arc',
                        ],
                    },
                }],
                ["OS=='win'", {
                    "sources": ["native/addon.cc"],
                }]
            ],
        }
    ]
}
