{
    "targets": [
        {
            "target_name": "addon",
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
