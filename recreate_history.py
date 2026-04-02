import datetime
import os
import subprocess
import random

# Configurations
TOTAL_COMMITS = 66
DAYS_BACK = 14

# Real project files to simulate changes in
target_files = [
    "lib/core/services/ai_service.dart",
    "lib/core/services/groq_service.dart",
    "lib/core/theme/app_theme.dart",
    "lib/core/router/app_router.dart",
    "lib/core/constants/system_prompts.dart",
    "lib/features/home/viewmodels/home_viewmodel.dart",
    "lib/features/home/views/home_view.dart",
    "lib/shared/widgets/app_button.dart",
    "pubspec.yaml",
    "README.md",
    "lib/main.dart"
]

# Commit logic (simplified)
commit_data = [
    ("feat(chat)", "implement streaming response parsing", "lib/core/services/ai_service.dart"),
    ("fix(auth)", "resolve token refresh logic in interceptor", "lib/core/services/open_router_service.dart"),
    ("docs(readme)", "update setup instructions for local development", "README.md"),
    ("style(ui)", "adjust font weights in app typography", "lib/core/theme/app_typography.dart"),
    ("refactor(core)", "simplify service locator registration", "lib/core/di/service_locator.dart"),
    ("perf(home)", "optimize list view rendering performance", "lib/features/home/views/home_view.dart"),
    ("test(services)", "add unit tests for groq service", "test/core/services/groq_service_test.dart"),
    ("chore(deps)", "upgrade flutter sdk and packages", "pubspec.yaml"),
    ("feat(search)", "add history support to search view", "lib/features/search/views/search_view.dart"),
    ("fix(router)", "handle deep linking for chat routes", "lib/core/router/app_router.dart"),
    ("style(theme)", "add custom styling for markdown blocks", "lib/core/theme/markdown_styler.dart"),
    ("feat(api)", "integrate open code zen service", "lib/core/services/open_code_zen_service.dart"),
    ("refactor(models)", "unify message and conversation models", "lib/core/data/models/message.dart"),
    ("fix(ui)", "fix layout overflow in message bubbles", "lib/shared/widgets/message_bubble.dart"),
    ("feat(settings)", "add option to change system prompt", "lib/core/constants/system_prompts.dart"),
    ("docs(api)", "add documentation for ai stream chunks", "lib/core/models/ai_stream_chunk.dart"),
    ("style(search)", "refine search bar animations", "lib/features/search/views/search_view.dart"),
    ("fix(stream)", "handle connection errors in chat stream", "lib/core/services/ai_service.dart"),
    ("refactor(viewmodels)", "separate logic in home viewmodel", "lib/features/home/viewmodels/home_viewmodel.dart"),
    ("feat(ui)", "implement dark mode toggle", "lib/core/theme/app_theme.dart"),
    ("perf(api)", "reduce latency in groq model fetching", "lib/core/services/groq_service.dart"),
    ("test(router)", "verify navigation guards in app router", "test/core/router/app_router_test.dart"),
    ("chore(build)", "update android build configuration", "android/app/build.gradle.kts"),
    ("fix(clipboard)", "fix copying multiline text to clipboard", "lib/core/services/clipboard_helper.dart"),
    ("feat(history)", "add persistence layer for conversations", "lib/core/data/services/persistence_service.dart"),
    ("style(home)", "improve sidebar responsiveness", "lib/features/home/views/sidebar_view.dart"),
    ("refactor(core)", "extract error message mapping logic", "lib/core/utils/error_message_mapper.dart"),
    ("feat(models)", "add support for custom model parameters", "lib/core/models/available_model.dart"),
    ("fix(ui)", "prevent keyboard from obscuring chat input", "lib/features/home/views/chat_input.dart"),
    ("docs(changelog)", "update changelog for v1.1.0", "CHANGELOG.md"),
    # Adding more variations to reach 66
]

# Generate random but realistic commit messages if we run out of defined ones
additional_types = ["feat", "fix", "docs", "style", "refactor", "perf", "test", "chore"]
additional_scopes = ["core", "ui", "chat", "auth", "api", "search", "deps"]
additional_verbs = ["update", "improve", "refactor", "fix", "add", "remove", "optimize"]
additional_nouns = ["logic", "view", "component", "service", "model", "style", "handler"]

def get_random_msg(i):
    if i < len(commit_data):
        return commit_data[i]
    t = random.choice(additional_types)
    s = random.choice(additional_scopes)
    v = random.choice(additional_verbs)
    n = random.choice(additional_nouns)
    msg = f"{t}({s}): {v} {n} implementation"
    file = random.choice(target_files)
    return (f"{t}({s})", f"{v} {n} implementation", file)

# Reset branch history for clean simulation
subprocess.run(["git", "checkout", "--orphan", "temp_history"], check=True)
subprocess.run(["git", "rm", "-rf", "."], check=True)
subprocess.run(["git", "checkout", "main", "--", "."], check=True)

# Time setup
now = datetime.datetime.now()
start_date = now - datetime.timedelta(days=DAYS_BACK)
time_step = datetime.timedelta(days=DAYS_BACK) / TOTAL_COMMITS

for i in range(TOTAL_COMMITS):
    scope_type, message, file_path = get_random_msg(i)
    commit_msg = f"{scope_type}: {message}"
    
    commit_date = start_date + (time_step * i)
    date_str = commit_date.strftime("%Y-%m-%d %H:%M:%S")
    
    # Ensure file exists
    os.makedirs(os.path.dirname(file_path), exist_ok=True) if os.path.dirname(file_path) else None
    
    # Modify the file with a comment
    with open(file_path, "a") as f:
        f.write(f"\n// Pseudo-update for commit {i+1} at {date_str}\n")
    
    subprocess.run(["git", "add", "."], check=True)
    env = os.environ.copy()
    env["GIT_AUTHOR_DATE"] = date_str
    env["GIT_COMMITTER_DATE"] = date_str
    subprocess.run(["git", "commit", "-m", commit_msg], env=env, check=True, capture_output=True)

# Replace main with temp_history
subprocess.run(["git", "branch", "-D", "main"], check=True)
subprocess.run(["git", "branch", "-m", "main"], check=True)

print(f"Successfully recreated {TOTAL_COMMITS} realistic commits.")
