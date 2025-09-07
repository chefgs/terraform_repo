package server

import (
	"context"
	"fmt"
)

// Server represents a server instance.
type Server struct {
	ID        string
	Name      string
	IPAddress string
	Port      int
}

// NewServer creates a new server instance.
func NewServer() *Server {
	return &Server{
		Port: 80, // Default port
	}
}

// Create creates a new server.
func (s *Server) Create(ctx context.Context, name string, ipAddress string, port int) error {
	// In a real provider, this would make an API call to create a server
	// For this example, we'll just set the values on the struct
	s.Name = name
	s.IPAddress = ipAddress
	s.Port = port
	s.ID = fmt.Sprintf("server-%s", name)

	return nil
}

// Read reads server information.
func (s *Server) Read(ctx context.Context, id string) error {
	// In a real provider, this would make an API call to get server details
	return nil
}

// Update updates server properties.
func (s *Server) Update(ctx context.Context, id string, name string, ipAddress string, port int) error {
	// In a real provider, this would make an API call to update server details
	s.Name = name
	s.IPAddress = ipAddress
	s.Port = port

	return nil
}

// Delete deletes a server.
func (s *Server) Delete(ctx context.Context, id string) error {
	// In a real provider, this would make an API call to delete a server
	return nil
}
