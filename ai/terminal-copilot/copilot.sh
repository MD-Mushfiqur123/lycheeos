# ~/.bashrc / ~/.zshrc addition for Lychee OS AI Copilot
_ai_explain_last_error() {
    local last_exit=$?
    local last_cmd=$(history 1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//')
    if [ $last_exit -ne 0 ]; then
        echo -e "\n🤖 AI: পাওয়া গেছে error। ব্যাখ্যা করছি..."
        curl -s http://localhost:11434/api/generate \
          -d "{\"model\":\"llama3.2:3b\",\"prompt\":\"Explain this Linux error briefly in Bengali or English: command='$last_cmd' exit_code=$last_exit\",\"stream\":false}" \
          | python3 -c "import sys,json; print(json.load(sys.stdin).get('response', 'Error contacting AI daemon.'))"
    fi
}
# Bind to prompt command
PROMPT_COMMAND="_ai_explain_last_error; $PROMPT_COMMAND"

# Usage: type 'ai "কীভাবে disk usage দেখবো?"'
ai() { 
    curl -s http://localhost:11434/api/generate \
      -d "{\"model\":\"llama3.2:3b\",\"prompt\":\"$*\",\"stream\":false}" \
      | python3 -c "import sys,json; print(json.load(sys.stdin).get('response', ''))"
}
