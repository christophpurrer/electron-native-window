{
    "targets": [
        {
            "target_name": "addon",
            "conditions": [
                ["OS=='mac'", {
                    "sources": ["native/*.mm"],
                }],
                ["OS=='win'", {
                    "sources": ["native/*.cc"],
                }]
            ],
        }
    ]
}
