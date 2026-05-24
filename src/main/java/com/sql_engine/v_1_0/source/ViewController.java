package com.sql_engine.v_1_0.source;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ViewController {

    @GetMapping("/")
    public String index() {
        return "index";
    }

    @GetMapping("/chat")
    public String chat() {
        return "Pages/chat";
    }

    @GetMapping("/settings")
    public String settings() {
        return "Pages/settings";
    }
}
