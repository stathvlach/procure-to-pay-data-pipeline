class ActionsRegistry:
    def __init__(self):
        self.handlers_ = {}
    
    def register(self, name, handler):
        """
        """
        if name in self.handlers_:
            raise ValueError(f"Action '{name}' already registered")
        self.handlers_[name] = handler
    
    def execute(self, action_name, params):
        """
        """
        handler = self.handlers_.get(action_name)
        if not handler:
            raise KeyError(f"Unknown action: {action_name}")
        return handler(params)
    
    def available_actions(self):
        """
        """
        return list(self.handlers_.keys())