use clap::{Parser, Subcommand};
use anyhow::Result;

pub mod resolver;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Install packages
    Install {
        packages: Vec<String>,
        #[arg(long)]
        root: Option<String>,
    },
    /// Remove packages
    Remove {
        packages: Vec<String>,
    },
    /// Update package database
    Update,
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Install { packages, root } => {
            println!("UPM: Resolving dependencies for {:?}", packages);
            if let Some(r) = root {
                println!("Using target rootfs: {}", r);
            }
            
            // Mock dependency resolution using our pubgrub wrapper
            for pkg in packages {
                match resolver::pubgrub::solve_deps(pkg, "latest") {
                    Ok(_) => println!("Successfully resolved {}", pkg),
                    Err(e) => eprintln!("Failed to resolve {}: {}", pkg, e),
                }
            }
            println!("Installation successful.");
        }
        Commands::Remove { packages } => {
            println!("UPM: Removing {:?}", packages);
        }
        Commands::Update => {
            println!("UPM: Syncing package database from mirrors...");
        }
    }

    Ok(())
}
